FROM docker.dragonfly.co.nz/dragonverse-18.04:latest

RUN Rscript -e 'install.packages("bsts")'