const ControleMarchandise = artifacts.require("ControleMarchandise");

contract("ControleMarchandise", (accounts) => {
  let controleMarchandise;

  const [admin, importateur, douane, autoritePortuaire, transporteur] = accounts;

  beforeEach(async () => {
    controleMarchandise = await ControleMarchandise.new({ from: admin });
  });

  it("devrait permettre à l'importateur d'ajouter une marchandise", async () => {
    const nomMarchandise = "Marchandise 1";
    await controleMarchandise.ajouterMarchandise(nomMarchandise, { from: importateur });

    const marchandise = await controleMarchandise.consulterMarchandise(1);
    assert.equal(marchandise.nom, nomMarchandise, "Le nom de la marchandise doit être correct");
    assert.equal(marchandise.statut, 0, "Le statut de la marchandise doit être NON_CONTROLE");
  });

  it("devrait permettre à la douane de contrôler une marchandise", async () => {
    const nomMarchandise = "Marchandise 2";
    await controleMarchandise.ajouterMarchandise(nomMarchandise, { from: importateur });

    await controleMarchandise.controlerMarchandise(1, { from: douane });

    const marchandise = await controleMarchandise.consulterMarchandise(1);
    assert.equal(marchandise.statut, 1, "Le statut de la marchandise doit être CONTROLE");
  });

  it("devrait permettre à l'autorité portuaire de bloquer une marchandise", async () => {
    const nomMarchandise = "Marchandise 3";
    await controleMarchandise.ajouterMarchandise(nomMarchandise, { from: importateur });
    await controleMarchandise.controlerMarchandise(1, { from: douane });

    await controleMarchandise.bloquerMarchandise(1, { from: autoritePortuaire });

    const marchandise = await controleMarchandise.consulterMarchandise(1);
    assert.equal(marchandise.statut, 3, "Le statut de la marchandise doit être BLOQUE");
  });

  it("devrait permettre à l'autorité portuaire de débloquer une marchandise", async () => {
    const nomMarchandise = "Marchandise 4";
    await controleMarchandise.ajouterMarchandise(nomMarchandise, { from: importateur });
    await controleMarchandise.controlerMarchandise(1, { from: douane });
    await controleMarchandise.bloquerMarchandise(1, { from: autoritePortuaire });

    await controleMarchandise.debloquerMarchandise(1, { from: autoritePortuaire });

    const marchandise = await controleMarchandise.consulterMarchandise(1);
    assert.equal(marchandise.statut, 1, "Le statut de la marchandise doit être CONTROLE après le déblocage");
  });

  it("devrait permettre au transporteur de mettre en transit une marchandise", async () => {
    const nomMarchandise = "Marchandise 5";
    await controleMarchandise.ajouterMarchandise(nomMarchandise, { from: importateur });
    await controleMarchandise.controlerMarchandise(1, { from: douane });

    await controleMarchandise.mettreEnTransit(1, { from: transporteur });

    const marchandise = await controleMarchandise.consulterMarchandise(1);
    assert.equal(marchandise.statut, 2, "Le statut de la marchandise doit être EN_TRANSIT");
  });
});

