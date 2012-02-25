PROYECTO TOPICOS ESPACIALES EN TELEMATICA
=========================================
pd: No tenemos tilde.

INTEGRANTES
-----------

* Daniel Munera Sanchez
* Ernesto Javier Quintero
* Jorge Andres Gaviria Lopez


REQUERIMIENTOS PARA EJECUTAR
----------------------------

* Ruby 1.9.2 
* Gem sqlite3
* Gem highline

COMO EJECUTAR
-------------

* Para ejecutar el servidor debemos ir a la carpeta donde se encuentra el archivo startServer.rb y ejecutar el siguiente comando:

<code>
	ruby startServer.rb [host] [port] => 
	Ej. ruby startServer.rb localhost 3030
<code>
	
* Para ejecutar un cliente debemos ir a la carpeta donde se encuentra el archivo startClient.rb y ejecutar el siguiente comando:

<code>
	ruby startClient.rb [nickname] [role] [host-server] [port-server] =>
	Ej. ruby startClient.rb jorge client localhost 3030
<code>

* Cada usuario tiene un comando help para obtener informacion acerca de los comandos validos.
	
* Los usuarios editor y admin, tienen unas claves para ingresar, la clave de editor es editor y la de admin es admin.

* Si depronto el servidor esta muy lento en responder es por un asunto de la gema de sqlite del servidor, en tal caso ejecute
el comando:

<code> git checkout nodb <code>
Para informacion vaya a la carpeta documents.