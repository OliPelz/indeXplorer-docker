FROM rocker/r-ver:3.3.2

MAINTAINER Oliver Pelz "o.pelz@gmail.com"

#### things we need for compiling R and Perl libraries
#### and another deb pkgs we later need for the R libraries to compile or run
RUN apt-get update && apt-get install -y  \
    wget \
    sudo \
    git \
    libssl-dev \
    libcairo2-dev \
    libxt-dev \
    gdebi
    
# install the shiny server debian package from r-studio
RUN wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-1.5.3.838-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f ss-latest.deb 

COPY ./shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

# now to the R part...

# first we need devtools for all the installation of all further packages
RUN R -e 'install.packages("devtools", repos = "http://cloud.r-project.org/")'

# install all the packages we need from cran, bioconductor and github

# first to install bioconductor R packages
#RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("BiocParallel")'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("DESeq2")'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("topGO")'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("flowCore")'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("GO.db")'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("org.Hs.eg.db")'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("org.Mm.eg.db")'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite("org.Dm.eg.db")'

# to install R packages from CRAN
RUN R -e 'devtools::install_version("shiny", version = "1.0.3", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("pheatmap", version = "1.0.8", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("RColorBrewer", version = "1.1-2", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("sendmailR", version = "1.2-1", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("plyr", version = "1.8.4", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("scales", version = "0.4.1", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("gsl", version = "1.9-10.3", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("ggvis", version = "0.4.3", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("colorRamps", version = "2.3", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("ggplot2", version = "2.2.1", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("BMS", version = "0.3.4", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("reshape2", version = "1.4.2", repos = "http://cloud.r-project.org/")'


# to install R packages from github
RUN R -e 'devtools::install_github("hms-dbmi/scde", ref = "5049863")'
RUN R -e 'devtools::install_github("AnalytixWare/ShinySky", ref = "15c29be")'

# cleaning up downloaded deb packages for keeping clean our docker image
RUN apt-get -qq clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# for CPAN to auto say yes to every question

ENV PERL_MM_USE_DEFAULT=1
RUN perl -MCPAN -e 'CPAN::Shell->install("Bundle::CPAN")'

# now install some perl modules we need for xxx
RUN perl -MCPAN -e 'CPAN::Shell->install("LWP::UserAgent")'

# deploy indexexplorer 
#COPY ./xxx /srv/shiny-server/xxx/

# we will run the shiny app as user 
#RUN chown -R shiny:shiny /srv/shiny-server/xxx

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3838

ENTRYPOINT ["/docker-entrypoint.sh"]
# finally run
CMD ["start-app"]


