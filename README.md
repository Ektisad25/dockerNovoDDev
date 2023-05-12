# Welcome to Novo

The renaissance of programmable money
Novo reimagines the classic UTXO-based scalable technology by refining its core infrastructure and virtual machine. This enhancement unleashes the technology's considerably untapped potential for parallelizable transaction processing and Layer-1 programmability.

You can try it out using the following command.

```
docker run -d -p 8088:80 --name welcome-to-novo docker/welcome-to-novo
```
And open `http://localhost:8088` in your browser.

# Building

Maintainers should see [MAINTAINERS.md](MAINTAINERS.md).

Build and run:
```
docker build -t welcome-to-novo . 
docker run -d -p 8088:3000 --name welcome-to-novo welcome-to-novo
```
Open `http://localhost:8088` in your browser.
