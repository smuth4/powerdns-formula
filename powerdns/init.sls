{% from "powerdns/map.jinja" import powerdns with context %}

powerdns:
  pkg.installed:
    - name: {{ powerdns.server }}

powerdns-server-service:
  service.running:
    - name: {{ powerdns.service }}
    - enable: True
    - watch:
      - file: powerdns-server-config

powerdns-server-config:
  file.managed:
    - name: {{ powerdns.server_config }}
    - mode: '0600'
    - user: root
    - group: root
    - template: jinja
    - source: {{powerdns.server_config_src }}
    - require:
      - pkg: powerdns
