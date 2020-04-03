# Install R version 3.5
FROM rocker/verse:3.6.2

ENV http_proxy "http://10.85.4.54:8080"
ENV https_proxy "http://10.85.4.54:8080"

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
    cron 	
# add addition system dependencies but suffixing \ <package name> on the end of the apt-get update & apt-get install -y command

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lbzip2 \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    liblwgeom-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libssl-dev \
    libudunits2-dev \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    unixodbc-dev
    
    RUN apt-get update \
  && apt-get install -y --no-install-recommends \ 
    libv8-dev \
    libnode-dev \
    libprotobuf-dev

# Download and install ShinyServer (latest version)
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

# Install R packages that are required!

RUN R -e "install.packages(c('shiny','dplyr','openxlsx','ggplot2','knitr','RColorBrewer','tidyr','shinyjs','stringr'), repos='http://cran.rstudio.com/')"

RUN R -e "install.packages(c('jsonlite', 'rgdal', 'rgeos','tmap', 'leaflet', 'sp', 'rlang'), repos='http://cran.rstudio.com/')"

RUN R -e "install.packages(c('readxl', 'rmapshaper', 'pryr', 'knitr', 'DT', 'shinydashboard'), repos='http://cran.rstudio.com/')"

# TODO: add further package if you need!
# RUN R -e "install.packages(c('<insert package name here>'))

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /App /srv/shiny-server

 RUN apt-get update \
  && apt-get install -y \ 
    xdg-utils \
    lynx

ENV BROWSER "lynx"




# Make the ShinyApp available at port 3838
EXPOSE 3838
EXPOSE 8787

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

CMD ["/usr/bin/shiny-server.sh"]
