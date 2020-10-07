const socket = io.connect('http://localhost:9001');
var migrations = document.getElementById('migrations');

socket.on('migration', function(data){
    migrations.innerHTML = '';
    data.forEach(function (element) {
        migrations.innerHTML += '<p>Island id: ' + element.nodeId + ', Generation: ' + element.generationNumber + ', Best individual: ' + element.bestFitnessValue + '</p>';
    })
});