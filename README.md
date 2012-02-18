ADS SERVER WITH SOCKETS
=======================

PD: no tengo tilde.

Esta es la implementacion del reto 1 de la materia topicos especiales en telematica. 


DESCRIPCION DEL PROBLEMA
-------------------------

El sistema debe tener un sistema de gestión que permita:
1. Canales y Mensajes: Canales a través de los cuales fluyen los Mensajes originados en un AdFuente (pueden haber varias fuentes
en un mismo Canal) hacia uno o más AdCliente
2. Envíos: 

* son los mensajes que son enviados por un AdFuente hacia un Canal y que le debe llegar a los AdCliente. Tenga en cuenta la situación cuando los clientes están o no en línea, que supuesto realizar al respecto.

* Los Canales son temáticos (deportes, tecnología, noticias, culinaria, bolsa, etc) y deben ser gestionados en el sistema (crear, modificar, borrar, etc un canal).

* Los anuncios son recibidos por los clientes en modo PUSH y PULL. Por anuncios PUSH se entiende la característica de recibir en un 	cliente mensajes sin haber sido solicitada explícitamente por el cliente. Por anuncios PULL se entiende cuando el cliente explícitamente recupera mensajes de un canal específico. Debe tener en cuenta que críterio utilizará para borrar mensajes de una cola.