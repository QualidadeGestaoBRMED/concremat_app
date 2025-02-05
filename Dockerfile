# Use a imagem base do R com Shiny
FROM rocker/shiny:4.2.2

# Instale pacotes adicionais de sistema
RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev

# Copie os arquivos do projeto para o contêiner
COPY . /srv/shiny-server/

# Instale os pacotes R necessários
RUN R -e "install.packages(c('shiny', 'bslib', 'DT', 'tidyverse', 'ghql', 'jsonlite'))"

# Exponha a porta do Shiny
EXPOSE 3838

# Comando para iniciar o Shiny
CMD ["/usr/bin/shiny-server"]



