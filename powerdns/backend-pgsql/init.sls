{% from "powerdns/map.jinja" import powerdns with context %}

powerdns-backend-pgsql:
  pkg.installed:
    - name: {{ powerdns.backend_pgsql }}

powerdns-backend-pgsql-config:
  file.managed:
    - name: {{ powerdns.backend_pgsql_config }}
    - makedirs: True
    - mode: '0600'
    - user: root
    - group: root
    - template: jinja
    - source: {{ powerdns.backend_pgsql_config_src }}
    - require:
      - pkg: powerdns-backend-pgsql

powerdns-remove-simplebind:
  file.absent:
    - name: /etc/powerdns/pdns.d/pdns.simplebind

powerdns-server-service-pgsql:
  service.running:
    - name: {{ powerdns.service }}
    - enable: True
    - watch:
      - file: powerdns-backend-pgsql-config