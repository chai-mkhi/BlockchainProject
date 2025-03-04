// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ControleMarchandise is AccessControl {
    using Counters for Counters.Counter;
    using Strings for uint256;
    
   bytes32 public constant DOUANE_ROLE = keccak256("DOUANE");
   bytes32 public constant IMPORTATEUR_ROLE = keccak256("IMPORTATEUR");
   bytes32 public constant TRANSPORTEUR_ROLE = keccak256("TRANSPORTEUR");
   bytes32 public constant AUTORITE_PORTUAIRE_ROLE = keccak256("AUTORITE_PORTUAIRE");



    enum Statut { NON_CONTROLE, CONTROLE, EN_TRANSIT, BLOQUE }
    
    struct Marchandise {
        uint256 id;
        string nom;
        Statut statut;
        uint256 timestampValidation;
        bytes32 hashAuthenticite;
    }
    
    Counters.Counter private _marchandiseIds;
    mapping(uint256 => Marchandise) private marchandises;

    event MarchandiseAjoutee(uint256 id, string nom, bytes32 hashAuthenticite, address importateur);
    event MarchandiseControlee(uint256 id, uint256 timestampValidation, address controleur);
    event MarchandiseBloquee(uint256 id, address autorite);
    event MarchandiseDebloquee(uint256 id, address autorite);
    event MarchandiseEnTransit(uint256 id, address transporteur);

 constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setRoleAdmin(IMPORTATEUR_ROLE, DEFAULT_ADMIN_ROLE);
    _setRoleAdmin(DOUANE_ROLE, DEFAULT_ADMIN_ROLE);
    _setRoleAdmin(TRANSPORTEUR_ROLE, DEFAULT_ADMIN_ROLE);
    _setRoleAdmin(AUTORITE_PORTUAIRE_ROLE, DEFAULT_ADMIN_ROLE);
}

    
    function ajouterMarchandise(string memory _nom) external onlyRole(IMPORTATEUR_ROLE) {
        _marchandiseIds.increment();
        uint256 newId = _marchandiseIds.current();
        bytes32 hashAuthenticite = keccak256(abi.encodePacked(_nom, newId, msg.sender));

        marchandises[newId] = Marchandise({
            id: newId,
            nom: _nom,
            statut: Statut.NON_CONTROLE,
            timestampValidation: 0,
            hashAuthenticite: hashAuthenticite
        });

        emit MarchandiseAjoutee(newId, _nom, hashAuthenticite, msg.sender);
    }
    
    function controlerMarchandise(uint256 _id) external onlyRole(DOUANE_ROLE) {
        require(marchandises[_id].id != 0, "Marchandise inexistante");
        require(marchandises[_id].statut == Statut.NON_CONTROLE, "Deja controlee");

        marchandises[_id].statut = Statut.CONTROLE;
        marchandises[_id].timestampValidation = block.timestamp;

        emit MarchandiseControlee(_id, block.timestamp, msg.sender);
    }
    
    function bloquerMarchandise(uint256 _id) external onlyRole(AUTORITE_PORTUAIRE_ROLE) {
        require(marchandises[_id].id != 0, "Marchandise inexistante");
        require(marchandises[_id].statut != Statut.BLOQUE, "Deja bloquee");

        marchandises[_id].statut = Statut.BLOQUE;

        emit MarchandiseBloquee(_id, msg.sender);
    }
    
    function debloquerMarchandise(uint256 _id) external onlyRole(AUTORITE_PORTUAIRE_ROLE) {
        require(marchandises[_id].id != 0, "Marchandise inexistante");
        require(marchandises[_id].statut == Statut.BLOQUE, "La marchandise n'est pas bloquee");

        marchandises[_id].statut = Statut.CONTROLE; // Remet à l’état contrôlé

        emit MarchandiseDebloquee(_id, msg.sender);
    }
    
    function mettreEnTransit(uint256 _id) external onlyRole(TRANSPORTEUR_ROLE) {
        require(marchandises[_id].id != 0, "Marchandise inexistante");
        require(marchandises[_id].statut == Statut.CONTROLE, "La marchandise doit etre controlee avant transit");

        marchandises[_id].statut = Statut.EN_TRANSIT;

        emit MarchandiseEnTransit(_id, msg.sender);
    }
    
    function consulterMarchandise(uint256 _id) external view returns (Marchandise memory) {
        require(marchandises[_id].id != 0, "Marchandise inexistante");
        return marchandises[_id];
    }

    function ajouterRole(address _compte, bytes32 _role) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(_role, _compte);
    }
}
