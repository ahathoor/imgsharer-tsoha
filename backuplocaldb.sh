PGPASSWORD=mikko pg_dump -Fc --no-acl --no-owner -h localhost -U postgres mydb > mydb.dump
echo "local db dumped to ./mydb.dump"
echo "Upload the file to the internets and"
echo "paste the url where the backup resides"
read BACKUP
heroku pgbackups:restore HEROKU_POSTGRESQL_BLUE_URL $BACKUP --confirm glacial-savannah-7038

