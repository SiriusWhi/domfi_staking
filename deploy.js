const ethers = require('ethers')

const CLT = require('./build/contracts/DominationToken.json')
const CLTX = require('./build/contracts/DominationXToken.json')
const Destaking = require('./build/contracts/Destaking.json')
const DestakingFarm = require('./build/contracts/DestakingFarm.json')

const provider = new ethers.providers.JsonRpcProvider(
  process.env.RINKEBY_CLIENT_URL,
)

let wallet = new ethers.Wallet.fromMnemonic(process.env.NMONIC)
wallet = wallet.connect(provider)

async function exec() {
  const CLTFactroy = new ethers.ContractFactory(
    // eslint-disable-line
    CLT.abi,
    CLT.bytecode,
    wallet,
  )
  const deploy_CLT = await CLTFactroy.deploy()
  console.log(deploy_CLT)

  const CLTXFactroy = new ethers.ContractFactory(
    CLTX.abi,
    CLTX.bytecode,
    wallet,
  )
  const deploy_CLTX = await CLTXFactroy.deploy()
  console.log(deploy_CLTX)

  const DestakingFactroy = new ethers.ContractFactory(
    Destaking.abi,
    Destaking.bytecode,
    wallet,
  )

  const timestamp = Date.now()

  const deploy_Destaking = await DestakingFactroy.deploy(
    'CE STAKING',
    deploy_CLT.address,
    timestamp,
    timestamp + 86400000,
    timestamp + 86400000 + 86400000,
    timestamp + 86400000 + 86400000 + 86400000,
    '33171875000000000000000000',
  )
  console.log(deploy_Destaking)

  const DestakingFarmFactroy = new ethers.ContractFactory(
    DestakingFarm.abi,
    DestakingFarm.bytecode,
    wallet,
  )

  const deploy_DestakingFarm = await DestakingFarmFactroy.deploy(
    'CE STAKING FARM',
    deploy_CLT.address,
    deploy_CLTX.address,
    timestamp,
    timestamp + 86400000,
    timestamp + 86400000 + 86400000,
    timestamp + 86400000 + 86400000 + 86400000,
    '3300000000000000000000',
  )
  console.log(deploy_DestakingFarm)
}

exec()
