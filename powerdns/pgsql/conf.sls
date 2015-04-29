{% from "powerdns/map.jinja" import powerdns with context %}

{% set dbuser_host = salt['grains.get']('fqdn','localhost') %}

{% set backend_config = salt['pillar.get']('powerdns:backend-mysql', {}) %}
{% set dbhost = backend_config.get('gpgsql-host','pdns') %}
{% set dbname = backend_config.get('gpgsql-dbname','pdns') %}
{% set dbuser = backend_config.get('gpgsql-user','pdns') %}
{% set dbpass = backend_config.get('gpgsql-password','secret') %}

{% set cxnuser = backend_config.get('connection-user','root') %}
{% set cxnpass = backend_config.get('connection-pass','rootpass') %}

powerdns-backend-pgsql_db:
  postgres.db_create:
    - name: {{ dbname }}
    - host: {{ dbhost }}
    - user: {{ cxnuser }}
    - password: '{{ cxnpass }}'

powerdns-backend-pgsql_user:
  postgres.user_create:
    - name: {{ dbuser }}
    - host: {{ dbhost }}
    - user: {{ cxnuser }}
    - password: '{{ cxnpass }}'
    - rolepassword: '{{ dbpass }}'
    - require:
      - postgres.db_create: powerdns-backend-pgsql_db

powerdns-backend-pgsql_ownership:
  postgres.owner_to:
    - dbname: {{ dbname }}
    - ownername: {{ dbuser }}
    - host: {{ dbhost }}
    - user: {{ cxnuser }}
    - password: '{{ cxnpass }}'
    - require:
      - postgres.user_create: powerdns-backend-pgsql_user

powerdns-backend-pgsql_schema:
  file.managed:
    - name: /tmp/powerdns-mysql-schema.sql
    - source: salt://powerdns/files/powerdns-mysql-schema.sql
    - user: root
    - group: root
    - mode: 0644
    - unless: PGPASSWORD='{{dbpass}}' psql -U{{dbuser}} -h{{dbhost}} {{ dbname }} -c "SELECT * FROM domains;"
    - require:
      - mysql_grants: powerdns-backend-pgsql_ownership


powerdns-backend-pgsql_run_script:
  cmd.run:
    - name: PGPASSWORD='{{dbpass}}' psql -U{{dbuser}} -h{{dbhost}} {{ dbname }} -f 
    - unless: PGPASSWORD='{{dbpass}}' psql -U{{dbuser}} -h{{dbhost}} {{ dbname }} -c "SELECT * FROM domains;"
    - require:
      - file: powerdns-backend-pgsql_schema
