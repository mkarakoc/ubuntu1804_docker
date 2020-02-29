FROM ubuntu:18.04

MAINTAINER Mesut Karakoç <mesudkarakoc@gmail.com>

### create "main" user with password "Docker!"
RUN useradd -ms /bin/bash main      && \
    echo "main:Docker!" | chpasswd  && \
    usermod -aG sudo main

# force the container to use bash
ENV SHELL "/bin/bash"
ENV LANG tr_TR.UTF-8
ENV LANGUAGE us

# set working directory to home directory of user "main"
WORKDIR /home/main
   
# update and install necessary ubuntu packages
RUN apt-get update                                      && \
    apt-get install -y locales                          && \
    apt-get install -y build-essential                  && \
    apt-get install -y firefox                          && \
    apt-get install -y konsole                          && \
    apt-get install -y gedit                            && \
    apt-get install -y sudo                             && \
    apt-get install -y git                              && \
    apt-get install -y m4                               && \
    apt-get install -y jq                               && \
    apt-get install -y python cython python-dev         && \
    apt-get install -y python-pip python-setuptools     && \
    apt-get install -y python3 cython3 python3-dev      && \
    apt-get install -y python3-pip python3-setuptools  

RUN locale-gen tr_TR.UTF-8    
    
RUN pip install matplotlib  && \
    pip install sympy       && \
    pip install symengine   && \
    pip install jupyter

RUN pip3 install matplotlib  && \
    pip3 install sympy       && \
    pip3 install symengine   && \
    pip3 install jupyter

RUN cd /usr/local/share/jupyter/kernels/python2 && \
    mv kernel.json temp.json && \
    jq -r '.argv[0] = "python2"' temp.json > kernel.json 
    
RUN cd /usr/local/share/jupyter/kernels/python3 && \
    mv kernel.json temp.json && \
    jq -r '.argv[0] = "python3"' temp.json > kernel.json 

    
RUN pip3 install jupyter_nbextensions_configurator  && \
    pip3 install jupyter_contrib_core


# GMP / MPFR / FLIN2 / ARB install
# put flint2 and arb to path
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/home/main/pylibs/flint2:/home/main/pylibs/arb"    

ADD pylibs             /home/main/pylibs
ADD flint_tests        /home/main/flint_tests
RUN chown -R main:main /home/main/pylibs        && \
    chown -R main:main /home/main/flint_tests


RUN cd ./pylibs                 && \
    tar -xvf gmp-6.1.2.tar.gz   && \
    cd ./gmp-6.1.2/             && \
    ./configure                 && \
    make                        && \
    make install                && \
    cd ..

RUN cd ./pylibs                 && \
    tar -xvf mpfr-4.0.2.tar.gz  && \
    cd ./mpfr-4.0.2/            && \
    ./configure                 && \
    make                        && \
    make install                && \
    cd ..

RUN cd ./pylibs             && \
    tar -xvf flint2.tar.gz  && \
    cd ./flint2/            && \
    ./configure             && \
    make                    && \
    make install            && \
    cd ..

RUN cd ./pylibs          && \
    tar -xvf arb.tar.gz  && \
    cd ./arb/            && \
    ./configure          && \
    make                 && \
    make install         && \
    cd ..
    
RUN cd ./pylibs                   && \
    tar -xvf python-flint.tar.gz  && \
    cd ./python-flint             && \
    python ./setup.py build_ext --include-dirs=/home/main/pylibs/flint2:/home/main/pylibs/arb --library-dirs=/home/main/pylibs/flint2:/home/main/pylibs/arb && \
    python setup.py install       && \
    python3 ./setup.py build_ext --include-dirs=/home/main/pylibs/flint2:/home/main/pylibs/arb --library-dirs=/home/main/pylibs/flint2:/home/main/pylibs/arb && \
    python3 setup.py install       && \    
    cd ..

# start "main" user
USER main      
    
# install and enable Jupyter extensions
RUN mkdir /home/main/.ipython                       && \
    mkdir /home/main/.ipython/nbextensions          && \
    cd /home/main/.ipython                          && \
    git clone https://github.com/ipython-contrib/jupyter_contrib_nbextensions && \
    cp -rf jupyter_contrib_nbextensions/src/jupyter_contrib_nbextensions/nbextensions/* /home/main/.ipython/nbextensions/ && \
    jupyter nbextensions_configurator enable --user         && \
    jupyter nbextension enable hide_input_all/main          && \ 
    jupyter nbextension enable livemdpreview/livemdpreview  && \
    jupyter nbextension enable rubberband/main              && \ 
    jupyter nbextension enable toc2/main                    && \ 
    jupyter nbextension enable varInspector/main            && \ 
    jupyter nbextension enable collapsible_headings/main    && \ 
    jupyter nbextension enable hinterland/hinterland        && \ 
    jupyter nbextension enable snippets_menu/main           && \ 
    jupyter nbextension enable execute_time/ExecuteTime     && \ 
    jupyter nbextension enable hide_input/main              && \ 
    jupyter nbextension enable runtools/main                && \ 
    jupyter nbextension enable toggle_all_line_numbers/main && \
    jupyter nbextension enable equation-numbering/main
