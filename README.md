# PowerDNS Zone Cleaner
Delete zone(s) from slave PowerDNS server(s) when you remove zone from master.

Put script in master server. Be sure that master can reach slave server via SSH. Launch script and it will compare zones in master with zones in slave PowerDNS server. If slave server have zones which is not present in master - script will delete them from slave.

Script can be edited to do cleaning vice versa.

Run script on CRON to automate cleanup.
