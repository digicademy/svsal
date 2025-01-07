#! /bin/sh

# if [ -z "$works" ] ; then
#    works=("W0010" "W0013" "W0066" "W0078" "W0999")
#    works=( W0013 W0066 W0078 W0999 )
# fi
# for work in ${works[@]} ; do
#    export wid=$work
#    echo "Indexing wid=$wid ..."
#    time sudo -u sphinxsearch indexer --all --rotate
#    time sudo -u sphinxsearch indexer --merge salamanca_base salamanca_base --rotate
#    time sudo -u sphinxsearch indexer --merge salamanca_lemmatized_lat salamanca_lemmatized_lat --rotate
# done

# export wid="W0001&wid=W0002&wid=W0003&wid=W0004&wid=W0005&wid=W0006&wid=W0007&wid=W0008&wid=W0010&wid=W0011&wid=W0012&wid=W0013&&wid=W0014&wid=W0015&wid=W0039&wid=W0078&wid=W0092&wid=W0114"
# export wid="W0001&wid=W0002&wid=W0003&wid=W0004&wid=W0005&wid=W0006&wid=W0007&wid=W0008&wid=W0011&wid=W0012&wid=W0013&&wid=W0014&wid=W0015&wid=W0039&wid=W0078&wid=W0092&wid=W0114"
# wordforms preprocessing: delete lines containing "_" or "+" in order to avoid wordform duplication in output

# find /var/data/existdb/data/export -type f -name "*.snippet.xml" -exec sed -i 's| xmlns:sphinx="https://www.salamanca.school/xquery/sphinx"||g' {} + >/etc/sphinxsearch/indexer.log 2>&1

indexer --all --rotate --quiet | grep -v "duplicate" > /var/log/dockerservices/indexer.log
