let
  exp-01-example-com = (import ../exp-01.example.com).exp-01-example-com;
in
''
worker_processes 4;
pid /tmp/nginx.pid;
error_log /tmp/error.log;

events {
  worker_connections 768;
}

http {
  default_type text/plain;

  access_log /tmp/access.log;
  error_log  /tmp/error.log;

  client_body_temp_path /tmp/nginx-client-body-temp;
  proxy_temp_path       /tmp/nginx-proxy-temp;
  fastcgi_temp_path     /tmp/nginx-fastcgi-temp;
  uwsgi_temp_path       /tmp/nginx-uwsgi-temp;
  scgi_temp_path        /tmp/nginx-scgi-temp;

  server {
    listen  8080;
    server_name exp-01.example.com;
    root ${exp-01-example-com}/_site;
  }
}
''
