javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Monopoly Game", function () {
  let owner, player1, player2;
  let monopolyToken, monopolyProperty, monopolyGame;

  beforeEach(async function () {
    [owner, player1, player2] = await ethers.getSigners();

    // Déploiement des contrats
    const MonopolyToken = await ethers.getContractFactory("MonopolyToken");
    monopolyToken = await MonopolyToken.deploy();
    await monopolyToken.deployed();

    const MonopolyProperty = await ethers.getContractFactory("MonopolyProperty");
    monopolyProperty = await MonopolyProperty.deploy();
    await monopolyProperty.deployed();

    const MonopolyGame = await ethers.getContractFactory("MonopolyGame");
    monopolyGame = await MonopolyGame.deploy(monopolyProperty.address, monopolyToken.address);
    await monopolyGame.deployed();

    // Lier les contrats entre eux
    await monopolyToken.setGameContract(monopolyGame.address);
    await monopolyProperty.setGameContract(monopolyGame.address);
  });

  it("Devrait permettre d'acheter une propriété", async function () {
    const PROPERTY_PRICE = ethers.utils.parseEther("100");

    // Distribuer des tokens au joueur 1
    await monopolyToken.distributeTokens(player1.address, PROPERTY_PRICE);

    // Autoriser le contrat de jeu à dépenser les tokens du joueur 1
    await monopolyToken.connect(player1).approve(monopolyGame.address, PROPERTY_PRICE);

    // Acheter une propriété
    await expect(monopolyGame.connect(player1).buyProperty(0))
      .to.emit(monopolyGame, "PropertyBought")
      .withArgs(player1.address, 0, PROPERTY_PRICE);

    // Vérifier que la propriété appartient bien au joueur 1
    expect(await monopolyProperty.ownerOfProperty(0)).to.equal(player1.address);
  });

  it("Devrait empêcher d'acheter une propriété sans autorisation des tokens", async function () {
    await expect(monopolyGame.connect(player1).buyProperty(0)).to.be.revertedWith(
      "Token allowance too low"
    );
  });

  it("Devrait empêcher un joueur de posséder plus de 4 propriétés", async function () {
    const PROPERTY_PRICE = ethers.utils.parseEther("100");
    await monopolyToken.distributeTokens(player1.address, PROPERTY_PRICE.mul(5));
    await monopolyToken.connect(player1).approve(monopolyGame.address, PROPERTY_PRICE.mul(5));

    for (let i = 0; i < 4; i++) {
      await monopolyGame.connect(player1).buyProperty(i);
    }

    await expect(monopolyGame.connect(player1).buyProperty(4)).to.be.revertedWith(
      "Ownership limit reached"
    );
  });
});