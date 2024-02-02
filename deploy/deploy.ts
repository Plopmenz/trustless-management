import { Deployer } from "../web3webdeploy/types";

export interface TrustlessManagementDeploymentSettings {}

export interface TrustlessManagementDeployment {}

export async function deploy(
  deployer: Deployer,
  settings?: TrustlessManagementDeploymentSettings
): Promise<TrustlessManagementDeployment> {
  return {};
}
