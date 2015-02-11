{% from "powerdns/map.jinja" import powerdns with context %}

powerdns-backend-mysql:
  pkg.installed:
    - name: {{ powerdns.backend_mysql }}

powerdns-backend-mysql-config:
  file.managed:
    - name: {{ powerdns.backend_mysql_config }}
    - mode: '0600'
    - user: root
    - group: root
    - template: jinja
    - source: {{powerdns.backend_mysql_config_src }}
    - require:
      - pkg: powerdns-backend-mysql

powerdns-remove-simplebind:
  file.absent:
    - name: /etc/powerdns/pdns.d/pdns.simplebind
