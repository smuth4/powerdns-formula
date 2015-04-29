{% from "powerdns/map.jinja" import powerdns with context %}

powerdns-backend-mysql:
  pkg.installed:
    - name: {{ powerdns.backend_pgsql }}

powerdns-backend-mysql-config:
  file.managed:
    - name: {{ powerdns.backend_pgsql_config }}
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
