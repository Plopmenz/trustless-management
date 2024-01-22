import { Deployer } from "../../web3webdeploy/types";

export async function deployCounter(deployer: Deployer) {
  return await deployer.deploy({
    contract: "Counter",
  });
}
