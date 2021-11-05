# templateMatching
Normalized cross correlation for image template matching

Algoritmo para a determinação da localização aproximada dos aviões estacionados em um aeroporto.

Primeiramente foi feita uma etapa de filtragem composta por:
+ Average Filter: Para limpeza de ruido gaussiano
+ Notch Filter: Para a limpeza de componentes indesejados no domínio da Frequência
+ Median Filter: Para a remoção de ruído do tipo "salt and pepper"

![denoising](images/denoising.png?raw=true)

Em seguida foi gerado um template que corresponde à imagem a ser procurada - arquivo "images/plane.png". Este template foi rotacionado de -45º a 45º para abranger a detecção de aviões estacionados de modo irregular.

![rotate](images/rotate.png?raw=true)

Após isso foi feita uma correlação cruzada no espaço de cores YCbCr seguindo a equação abaixo:
![equation](images/equation.png?raw=true)


O maior valor encontrado na correlação indica que o template e o ponto avaliado na imagem são identicos, definindo um threshold é possível detectar a posição de qualquer imagem similar ao template.

![result](images/result.png?raw=true)

