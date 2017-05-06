# indeXplorer-docker

temporary location for a dockerfile for indeXplorer

first clone this git repo you see here

next change to this dir 
```
cd indeXplorer-docker
```

then clone indeXplorer inside the ```indeXplorer-docker``` dir using

```bash
git clone https://git.embl.de/velten/indeXplorer.git
```

then build docker image
```bash
docker build .
```

in order we can run the web app, we need to put some data in a specific folder and
define this folder as a docker run(time)  argument

for example define the following location on your host system
```
mkdir ~/indeXplorer_data
DATA_DIR=~/indeXplorer_data
```

copy some example data in it
```
cd $DATA_DIR
wget http://steinmetzlab.embl.de/shiny/indexplorer/data.zip
unzip -j data.zip
```

now run the container defining the local folder (providing a local folder is mandantory, otherwise the shiny webapp indeXplorer will throw an error when startin
g)
first do a  test
```
if ! [ -f $DATA_DIR/MASTER_ALL.rda ]; then echo "mandantory file for indeXplorer not found!"; fi
```
then run the app
```
docker run --rm -p 80:3838 -v $DATA_DIR:/data indeXplorer
```

following options are defined on running docker

verbose_logfiles creates extensive log files in ```/var/log/shiny-server```
```
verbose_logfiles=[TRUE,FALSE] 
```
e.g.
```
docker run --rm -p 80:3838 -e verbose_logfiles=TRUE -v $DATA_DIR:/data indeXplorer

```
