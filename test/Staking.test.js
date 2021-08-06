const { expect } = require('chai');
const { ethers } = require('hardhat');
const { BigNumber } = require('ethers');
const { time } = require('./helpers')

const totalDOM = BigNumber.from(300)
const lspExpiration = BigNumber.from(Math.round(Date.now() / 1000) + 12960000) // 86400 * 150 + currentTimeStamp

describe('Staking', function () {
	before(async function () {
		const ErcMock20 = await ethers.getContractFactory('ErcMock20')
		const Staking = await ethers.getContractFactory('Staking')
		this.DOM = await ErcMock20.deploy('DOM', 'DOM')
		this.LP = await ErcMock20.deploy('LP', 'LP')

		await this.DOM.deployed()
		await this.LP.deployed()

		this.staking = await Staking.deploy(
			this.LP.address, 
			this.DOM.address, 
			totalDOM, 
			lspExpiration
		)

		await this.staking.deployed()

		const users = await ethers.getSigners()
		this.stakers = users.slice(0, 3)

		const [alice, bob, carl] = this.stakers

		// set initial LP token balance and approve
		const aliceLP = this.LP.connect(alice)
		const bobLP = this.LP.connect(bob)
		const carlLP = this.LP.connect(carl)

		// set initial DOM token balance and approve
		const aliceDOM = this.DOM.connect(alice)

		await Promise.all([
			aliceLP.mint(100),
			bobLP.mint(100),
			carlLP.mint(100),

			aliceLP.approve(this.staking.address, 100),
			bobLP.approve(this.staking.address, 100),
			carlLP.approve(this.staking.address, 100),
		])

		await Promise.all([
			aliceDOM.mint(1000),
			aliceDOM.approve(this.staking.address, 1000),
		])

		await aliceDOM.transfer(this.staking.address, 1000)
	})

	it('Stake after firstStake', async function () {
		const [alice, bob, carl] = this.stakers
		const aliceStaking = this.staking.connect(alice)
		const bobStaking = this.staking.connect(bob)
		const carlStaking = this.staking.connect(carl)

		const aliceLP = this.LP.connect(alice)

		await aliceStaking.initialize()

		// after 1 day
		await time.increase(86400)
		// alice staked 30
		await aliceStaking.stake(30)
		expect(await aliceLP.balanceOf(alice.address)).to.eql(BigNumber.from(70))
		
		// after 5 days
		await time.increase(432000) // 86400 * 5
		// bob staked 20
		await bobStaking.stake(20)
		expect(await aliceLP.balanceOf(bob.address)).to.eql(BigNumber.from(80))

		expect(await aliceStaking.totalStaked()).to.eql(BigNumber.from(50))
		expect(await aliceStaking.totalStakedFor(alice.address)).to.eql(BigNumber.from(30))
		expect(await aliceStaking.totalStakedFor(bob.address)).to.eql(BigNumber.from(20))
		expect(await aliceStaking.remainingDOM()).to.eql(BigNumber.from(1000))

		const aliceInfo = await aliceStaking.Info(alice.address)
		expect(aliceInfo[0]).to.eql(BigNumber.from(0))
		expect(aliceInfo[1]).to.eql(BigNumber.from(1))
		expect(aliceInfo[2]).to.eql(BigNumber.from(0))

		const bobInfo = await bobStaking.Info(bob.address)
		expect(bobInfo[0]).to.eql(BigNumber.from(0))
		expect(bobInfo[1]).to.eql(BigNumber.from(1))
		expect(bobInfo[2]).to.eql(BigNumber.from(0))
	})

	it('Stake for', async function () {
		const [alice, bob, carl] = this.stakers
		const aliceStaking = this.staking.connect(alice)
		const bobStaking = this.staking.connect(bob)

		const aliceLP = this.LP.connect(alice)

		// bob staked 50 for carl
		await bobStaking.stakeFor(carl.address, 50)
		expect(await aliceLP.balanceOf(bob.address)).to.eql(BigNumber.from(30))

		expect(await aliceStaking.totalStaked()).to.eql(BigNumber.from(100))
		expect(await aliceStaking.totalStakedFor(carl.address)).to.eql(BigNumber.from(50))
	})

	it('Unstake date < 7 days', async function () {
		const [alice, bob, carl] = this.stakers
		const aliceStaking = this.staking.connect(alice)
		const carlStaking = this.staking.connect(carl)

		const aliceLP = this.LP.connect(alice)
		const aliceDOM = this.DOM.connect(alice)

		// carl unstaked 10
		await carlStaking.unstake(10)

		expect(await aliceLP.balanceOf(carl.address)).to.eql(BigNumber.from(110))
		expect(await aliceDOM.balanceOf(carl.address)).to.eql(BigNumber.from(0))
		expect(await aliceStaking.totalStaked()).to.eql(BigNumber.from(90))
		expect(await aliceStaking.totalStakedFor(carl.address)).to.eql(BigNumber.from(40))
		expect(await aliceStaking.remainingDOM()).to.eql(BigNumber.from(1000))
	})

	it('Unstake 7 days < date < REWARD_PERIOD = 120 days', async function () {
		const [alice, bob, carl] = this.stakers
		const aliceStaking = this.staking.connect(alice)
		const carlStaking = this.staking.connect(carl)

		const aliceLP = this.LP.connect(alice)
		const aliceDOM = this.DOM.connect(alice)

		// carl unstaked 10 after 40 days
		await time.increase(2937600) // 86400 * 34
		await carlStaking.unstake(10)

		expect(await aliceLP.balanceOf(carl.address)).to.eql(BigNumber.from(120))
		expect(await aliceDOM.balanceOf(carl.address)).to.eql(BigNumber.from(0))
		expect(await aliceStaking.totalStaked()).to.eql(BigNumber.from(80))
		expect(await aliceStaking.totalStakedFor(carl.address)).to.eql(BigNumber.from(30))
		expect(await aliceStaking.remainingDOM()).to.eql(BigNumber.from(1000))
	})

	it('Unstake REWARD_PERIOD = 120 days < date < LSP_PERIOD = 150 days', async function () {
		const [alice, bob, carl] = this.stakers
		const aliceStaking = this.staking.connect(alice)
		const carlStaking = this.staking.connect(carl)

		const aliceLP = this.LP.connect(alice)
		const aliceDOM = this.DOM.connect(alice)

		// carl unstaked 10 after 130 days
		await time.increase(7776000) // 86400 * 90
		await carlStaking.unstake(10)

		expect(await aliceLP.balanceOf(carl.address)).to.eql(BigNumber.from(130))
		expect(await aliceDOM.balanceOf(carl.address)).to.eql(BigNumber.from(0))
		expect(await aliceStaking.totalStaked()).to.eql(BigNumber.from(70))
		expect(await aliceStaking.totalStakedFor(carl.address)).to.eql(BigNumber.from(20))
		expect(await aliceStaking.remainingDOM()).to.eql(BigNumber.from(1000))
	})

	it('Unstake date > LSP_PERIOD = 150 days', async function () {
		const [alice, bob, carl] = this.stakers
		const aliceStaking = this.staking.connect(alice)
		const carlStaking = this.staking.connect(carl)

		const aliceLP = this.LP.connect(alice)
		const aliceDOM = this.DOM.connect(alice)

		// carl unstaked 10 after 160 days
		await time.increase(2592000) // 86400 * 30
		await carlStaking.unstake(10)

		expect(await aliceLP.balanceOf(carl.address)).to.eql(BigNumber.from(140))
		expect(await aliceDOM.balanceOf(carl.address)).to.eql(BigNumber.from(0))
		expect(await aliceStaking.totalStaked()).to.eql(BigNumber.from(60))
		expect(await aliceStaking.totalStakedFor(carl.address)).to.eql(BigNumber.from(10))
		expect(await aliceStaking.remainingDOM()).to.eql(BigNumber.from(1000))
	})

	it('withdrawLeftover', async function () {
		const [alice, bob, carl] = this.stakers
		const aliceStaking = this.staking.connect(alice)
		const aliceDOM = this.DOM.connect(alice)

		await aliceStaking.withdrawLeftover()
		expect(await aliceDOM.balanceOf(alice.address)).to.eql(BigNumber.from(300))
	})
})