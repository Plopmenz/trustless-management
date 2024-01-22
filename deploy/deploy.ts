import { Address, Deployer } from "../web3webdeploy/types";
import { deployCounter } from "./counters/Counter";
import { deployProxyCounter } from "./counters/ProxyCounter";

export interface DeploymentSettings {}

export interface Deployment {
  counter: Address;
  proxyCounter: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: DeploymentSettings
): Promise<Deployment> {
  const counter = await deployCounter(deployer);
  const proxyCounter = await deployProxyCounter(deployer, counter);
  return {
    counter: counter,
    proxyCounter: proxyCounter,
  };
}
