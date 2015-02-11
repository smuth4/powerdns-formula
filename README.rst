powerdns
========

Installs a basic powerdns server.
And optionally configures the backend for mysql.

Available states
================

.. contents::
    :local:

 ``powerdns.server``
 ---------

 Runs the states to install pdns-server, configure the common files.

 ``powerdns.backend-mysql``
 ----------------

 Runs the states to install the pdns-backend-mysql, configure the needed configfiles.


 ``powerdns.mysql``
 ----------------

 Creates a database, user and needed grants, and schema on a local or remote mysql-server for the pdns-backend-mysql.


Usage
=====

All the configuration for powerdns is done via pillar (pillar.example).
You can set all the package data depending on your operating system, every configuration option and all the configuration needed for the communication with mysql

