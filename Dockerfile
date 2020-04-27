# Install R version 3.6.1
FROM rocker/geospatial:3.6.1

ENV BROWSER "lynx"

ARG proxy_setting

ENV http_proxy $proxy_setting
ENV https_proxy $proxy_setting 

# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    cron \ 
    xdg-utils \
    lynx
    
# add addition system dependencies but suffixing \ <package name> on the end of the apt-get update & apt-get install -y command


# Download and install ShinyServer (latest version)
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

# Install R packages that are required!

RUN R -e "install.packages(c('shiny','dplyr','openxlsx','ggplot2','knitr','RColorBrewer','tidyr','shinyjs','stringr'), repos='http://cran.rstudio.com/')"

RUN R -e "install.packages(c('jsonlite', 'rgdal', 'rgeos','tmap', 'leaflet', 'sp', 'rlang'), repos='http://cran.rstudio.com/')"

RUN R -e "install.packages(c('readxl', 'rmapshaper', 'pryr', 'knitr', 'DT', 'shinydashboard'), repos='http://cran.rstudio.com/')"

RUN R -e "install.packages(c('sf', 'maptools', 'raster', 'plyr'), repos='http://cran.rstudio.com/')"

# TODO: add further package if you need!
# RUN R -e "install.packages(c('<insert package name here>'))

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /App /srv/shiny-server

# Make the ShinyApp available at port 3838
EXPOSE 3838
EXPOSE 8787

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

CMD ["/usr/bin/shiny-server.sh"]
