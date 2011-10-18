#!/bin/bash
#
# JonMyBackup
# Script de Backup para MySQL
# 2009.11.26
#
# - Efetua dump do banco MySQL em um arquivo .sql
# - Compacta em bzip2
# - Tira MD5Sum do arquivo, para checagem de integridade
# - Salva em pasta de backup com data e hora no filename.
#
# @author             Jonathas Rodrigues <jonathas arroba archlinux ponto us>
# @copyright         2009, Jonathas Rodrigues
# @version            1.0
# @license             http://opensource.org/licenses/gpl-license.php GNU Public License

# Data: Ano-Mes-Dia-Hora-Minuto-Segundo-Abreviação alfabética do fuso horário (por exemplo, BRT)
data=`date +%Y-%m-%d-%H-%M-%S-%Z`

# Variáveis de conexão
host="nomedohostaqui"
user="nomedousuarioaqui"
password="senhaaqui"
dbname="nomedobancodedadosaqui"

# Variáveis do script
backupdir="/home/jonathas/backupdb"
tmpdir="/tmp"
bz2file=$dbname-$data.tar.bz2
dump=$dbname.sql
md5file=$dbname-$data.md5

clear
echo '###############################'
echo '       JonMyBackup v1.0'
echo '  Script de Backup para MySQL'
echo '          2009.11.26'
echo '###############################'
echo

# Bloqueando execução como root
if [ `whoami` == 'root' ];then
	echo 'Por favor, por questão de segurança, não rode este programa como root!'
	exit 1
fi

# Função para fazer o dump do banco de dados em um arquivo .sql
dumpDB() {
	# Checando se o diretório temporário existe. Se não, criando um.
	if [ -e $tmpdir ]; then
		echo 'Diretório temporário ok...'
	else
		echo 'Criando diretório temporário...'
		mkdir $tmpdir
	fi
	
	# Executando dump
	echo 'Executando dump...'
	/usr/bin/mysqldump --opt -h $host -u$user -p$password $dbname > $tmpdir/$dump
}

# Função para compactar o dump para tar.bz2, com a formatação correta da data no filename
bzip2Compress() {
	cd $tmpdir
	echo 'Compactando dump...'
	tar cjf $bz2file $dump
	rm $dump
}

writeMD5Sum() {
	echo 'Criando MD5SUM...'
	echo `md5sum $bz2file` > $md5file
}

moveFiles() {
	# Checando se o diretório de Backup existe. Se não, criando um.
	if [ -e $backupdir ]; then
		echo 'Diretório de Backup ok...'
	else
		echo 'Criando diretório de Backup...'
		mkdir $backupdir
	fi

	mv $tmpdir/$md5file $backupdir
	mv $tmpdir/$bz2file $backupdir
	echo 'Backup feito com sucesso e armazenado no diretório de Backup!'
}

main() {
	dumpDB
	bzip2Compress
	writeMD5Sum
	moveFiles
}

main

