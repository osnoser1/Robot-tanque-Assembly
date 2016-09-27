# Robot-tanque-Assembly

El robot tanque autónomo fue un proyecto que se mandó a realizar en la materia de Labortatorio de Proyectos Digitales Avanzados, en la Universidad de Oriente - Núcleo Anzoátegui, Venezuela.
Dicho proyecto tenía como objetivo realizarlo utilizando el lenguaje de programación Assembly.

Para su construcción se utilizaron los siguientes componentes.
- Teensy 2.0++: con este sistema de desarrollo se utilizó el lenguaje AVR Assembly, de Atmel.
- Sensor ultrasónico PING))) de Parallax
- 4 sensores de linea analógicos.
- 2 servomotores: uno para el sistema de disparo, y otro para mover el sensor ultrasónico.

Este proyecto lo publico por lo siguiente:
- Creé una gran capa de abstracción en assembly, que permitirá utilizar todos estos componentes de una manera bastante sencilla, olvidando los detalles de implementación internos, con el objetivo de facilitarme al final, dotar al robot de ciertas funcionalidades, que sin la capa sería más propenso a errores, que tomaría más tiempo de implementar, y que dificilmente con el tiempo que teníamos hubiese sido posible.
- Dicha capa de abstracción está basada en la utilizada en Arduino, en el lenguaje de programación C++, por los que notarán que muchas rutinas poseen los mismos nombres, estos, para facilitar su utilización.
- Con la capa de abstracción, pude dar soluciones a problemas que habían, como el manejo de error en las lecturas de los sensores de linea, y en el movimiento del robot al detectar los bordes, y cruces. Además lo más importante, es que a la final, pude implementar la búsqueda y seguimiento del robot enemigo, en menos de una hora, sin errores.
- Hay muchas cosas que se pueden mejorar en el código, ya que fue implementado en contra del tiempo, con algunas malas prácticas.
- Ahora que culminé la materia, por los momentos, no tengo pensado y espero que no, volver a trabajar en este lenguaje.
- Y más importante: quizá a alguien le pueda ayudar este código, utilizar algunas rutinas de la implementación, y quizá, ¿por qué no?, ayudar a mejorarlo.
