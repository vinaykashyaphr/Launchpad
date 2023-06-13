-------------------------------------------------
Honeywell_Print-S1000D Network Deployment Instructions
-------------------------------------------------


1. Network "Honeywell_Print-S1000D" Deployment

The core "Honeywell_Print-S1000D" custom application files for Arbortext Editor should be copied to a single network location for use by multiple client systems.

e.g. shared drive letter mapping common to all users

V:\Honeywell_Print-S1000D
V:\Honeywell_Print-S1000D\client
V:\Honeywell_Print-S1000D\custom
V:\Honeywell_Print-S1000D\Honeywell_XSL-FO


Note: all future updates versions of "Honeywell_Print-S1000D" application files will be copied to this shared location and be used by all client users.



2. Workstation "Honeywell_Print-S1000D-client" Deployment

Copy network folder: 
V:\Honeywell_Print-S1000D\client\Honeywell_Print-S1000D-client

to workstation location:
C:\Honeywell_Print-S1000D-client
C:\Honeywell_Print-S1000D-client\Arbortext-HW_Print-client.bat


Use a text editor to modify "Arbortext-HW_Print-client.bat" file settings:


a) Set path to Arbortext Editor 6.0 M140 (64-bit) installed on client system:

e.g.
set ARBORTEXT_HOME=C:\Program Files\PTC\Arbortext Editor


b) Set path to network location of "Honeywell_Print-S1000D" custom application files

e.g.
set APTCUSTOM=V:\Honeywell_Print-S1000D\custom


c) Verify path and location of "Honeywell_Print-S1000D-client" files

e.g.
set HONEYWELL_PRINT_CLIENT=C:\Honeywell_Print-S1000D-client


Note: 
- configuration of the "C:\Honeywell_Print-S1000D-client\Arbortext-HW_Print-client.bat" is a one-time event
- updates to "V:\Honeywell_Print-S1000D" application files on shared network folder are automatically available to all client users on next launch of "C:\Honeywell_Print-S1000D-client\Arbortext-HW_Print-client.bat".








