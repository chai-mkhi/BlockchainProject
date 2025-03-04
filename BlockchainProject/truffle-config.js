module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",  
      port: 9545,  // Le port de Ganache
      network_id: "*", // Permet de se connecter à n'importe quel réseau
    },
  },
  compilers: {
    solc: {
      version: "0.8.17", // Version du compilateur Solidity
    },
  },
};
