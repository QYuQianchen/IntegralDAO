import { task } from "hardhat/config";
import { getExpectedContractAddress } from "../utils";

import {
  DemoNFT,
  DemoNFT__factory,
  DemoIntegralDAO,
  DemoIntegralDAO__factory,
  DemoTimeLock,
  DemoTimeLock__factory,
  DemoGovernor,
  DemoGovernor__factory
  // MyNftToken__factory,
  // MyGovernor,
  // MyGovernor__factory,
  // Timelock,
  // Timelock__factory,
} from "../../types";

task("deploy:Dao").setAction(async function (_, { ethers }) {
  const demoNftFactory: DemoNFT__factory = await ethers.getContractFactory("DemoNFT");
  const signerAddress = await demoNftFactory.signer.getAddress();
  const signer = await ethers.getSigner(signerAddress);
  const governorExpectedAddress = await getExpectedContractAddress(signer);
  const demoNft: DemoNFT = <DemoNFT>await demoNftFactory.deploy();
  await demoNft.deployed();

  const demoIntegralDAOFactory: DemoIntegralDAO__factory = await ethers.getContractFactory("DemoIntegralDAO");
  const demoIntegralDAO: DemoIntegralDAO = <DemoIntegralDAO>await demoIntegralDAOFactory.deploy(demoNft.address);
  await demoIntegralDAO.deployed();

  const demoTimeLockFactory: DemoTimeLock__factory = await ethers.getContractFactory("DemoTimeLock");
  const demoTimeLock: DemoTimeLock = <DemoTimeLock>await demoTimeLockFactory.deploy([governorExpectedAddress, signerAddress], [governorExpectedAddress, signerAddress]);
  await demoTimeLock.deployed();

  const demoGovernorFactory: DemoGovernor__factory = await ethers.getContractFactory("DemoGovernor");
  const demoGovernor: DemoGovernor = <DemoGovernor>await demoGovernorFactory.deploy(demoIntegralDAO.address, demoTimeLock.address);
  await demoGovernor.deployed();

  console.log("Dao deployed to: ", {
    governorExpectedAddress,
    governor: demoGovernor.address,
    timelock: demoTimeLock.address,
    daoToken: demoIntegralDAO.address,
    nftToken: demoNft.address,
  });

  // const timelockDelay = 2;
  // const tokenFactory: MyNftToken__factory = await ethers.getContractFactory("MyNftToken");
  // const signerAddress = await tokenFactory.signer.getAddress();
  // const signer = await ethers.getSigner(signerAddress);
  // const governorExpectedAddress = await getExpectedContractAddress(signer);

  // const token: MyNftToken = <MyNftToken>await tokenFactory.deploy();
  // await token.deployed();

  // const timelockFactory: Timelock__factory = await ethers.getContractFactory("Timelock");
  // const timelock: Timelock = <Timelock>await timelockFactory.deploy(governorExpectedAddress, timelockDelay);
  // await timelock.deployed();

  // const governorFactory: MyGovernor__factory = await ethers.getContractFactory("MyGovernor");
  // const governor: MyGovernor = <MyGovernor>await governorFactory.deploy(token.address, timelock.address);
  // await governor.deployed();

  // console.log("Dao deployed to: ", {
  //   governorExpectedAddress,
  //   governor: governor.address,
  //   timelock: timelock.address,
  //   token: token.address,
  // });
});