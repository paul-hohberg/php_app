if ! echo $PATH | grep -q /opt/mssql-tools/bin ; then
  export PATH=$PATH:/opt/mssql-tools/bin
fi