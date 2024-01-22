import { Address, Deployer } from "../../web3webdeploy/types";

export async function deployProxyCounter(deployer: Deployer, counter: Address) {
  return await deployer.deploy({
    contract: "ProxyCounter",
    args: [counter],
  });
}
