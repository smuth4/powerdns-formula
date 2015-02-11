{% from "powerdns/map.jinja" import powerdns with context %}

{% set dbuser_host = salt['grains.get']('fqdn','localhost') %}

{% set backend_config = salt['pillar.get']('powerdns:backend-mysql', {}) %}
{% set dbhost = backend_config.get('gmysql-host','pdns') %}
{% set dbname = backend_config.get('gmysql-dbname','pdns') %}
{% set dbuser = backend_config.get('gmysql-user','pdns') %}
{% set dbpass = backend_config.get('gmysql-password','secret') %}

{% set cxnuser = backend_config.get('connection-user','root') %}
{% set cxnpass = backend_config.get('connection-pass','rootpass') %}

include:
  - mysql.client

powerdns-backend-mysql_db:
  mysql_database.present:
    - name: {{ dbname }}
    - host: {{ dbuser_host }}
    - connection_user: {{ cxnuser }}
    - connection_pass: '{{ cxnpass }}'
    - connection_host: {{ dbhost }}
    - character_set: utf8
    - collate: utf8_bin

powerdns-backend-mysql_user:
  mysql_user.present:
    - name: {{ dbuser }}
    - host: {{ dbuser_host }}
    - connection_user: {{ cxnuser }}
    - connection_pass: '{{ cxnpass }}'
    - connection_host: {{ dbhost }}
    - password: '{{ dbpass }}'
    - require:
      - mysql_database: powerdns-backend-mysql_db

powerdns-backend-mysql_grants:
  mysql_grants.present:
    - grant: 'all privileges'
    - database: {{ dbname }}.*
    - user: {{ dbuser }}
    - host: {{ dbuser_host }}
    - connection_user: {{ cxnuser }}
    - connection_pass: '{{ cxnpass }}'
    - connection_host: {{ dbhost }}
    - require:
      - mysql_user: powerdns-backend-mysql_user 

powerdns-backend-mysql_schema:
  file.managed:
    - name: /tmp/powerdns-mysql-schema.sql
    - source: salt://powerdns/files/powerdns-mysql-schema.sql
    - user: root
    - group: root
    - mode: 0644
    - unless: mysql -u{{dbuser}} -p{{dbpass}} -h{{dbhost}} {{ dbname }} -e "SELECT * FROM domains;"
    - require:
      - mysql_grants: powerdns-backend-mysql_grants


powerdns-backend-mysql_run_script:
  cmd.run:
    - name: mysql -u{{dbuser}} -p{{dbpass}} -h{{dbhost}} {{ dbname }} < /tmp/powerdns-mysql-schema.sql
    - unless: mysql -u{{dbuser}} -p{{dbpass}} -h{{dbhost}} {{ dbname }} -e "SELECT * FROM domains;"
    - require:
      - file: powerdns-backend-mysql_schema
