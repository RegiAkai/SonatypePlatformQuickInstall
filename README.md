# SonatypePlatformQuickInstall
Instructions:
- Create and NGROK Acccount
- Place your AUTH_TOKEN in the ngrok.yml file
- Run `docker compose up -d`
- Run `docker exec -it nexus cat /nexus-data/admin.password` to get your admin password for nexus
  - IQ admin password is `admin123`
- Visit the Ngrok website and find your IQ and NXRM urls under the Enpoint section in the sidebar
  - Alternatively you can run `curl http://localhost:4040/api/tunnels` or visit that url to get the information in JSON
- Enjoy

