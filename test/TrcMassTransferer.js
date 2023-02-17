const _MassTransferer = artifacts.require('TrcMassTransferer');
const zeroAddr = "410000000000000000000000000000000000000000";
const _token = artifacts.require('EIP20Token');
 
contract('MetaCoin', accounts => {
  let token;
  let massTransferer;

  before(async () => {
  //   const result = await tronWrap.send('tre_setAccountBalance', [accounts[0], 10000000e6]);
    token = await _token.deployed();
  //   await token.mint(1000000e6);
  //   // massTransferer = await _MassTransferer.deployed()
  });

  it('should deploy as unpaused', async () =>{
    // const result = await tronWrap.send('tre_setAccountBalance', [accounts[0], 10000000e6]);
    // token = await _token.deployed();
    const user = accounts[0]
    const rec1 = accounts[1];
    const rec2 = accounts[2];
    const userInitialTokenBalance = await token.balanceOf(user);
    assert.equal(userInitialTokenBalance.toNumber(), 1000000e6, 'WTF')
    _MassTransferer.deployed().then(async instance => {
      console.log(await instance.getFee());
      instance.sendMain([rec1, rec2], [5000, 5000], {from: user, callValue: await instance.getFee()*2+5000*2}).then(async res=>{
        console.log(await tronWrap.trx.getTransaction(res));

      })
      console.log(await token.balanceOf(rec1));
      console.log(await token.balanceOf(rec2));
      // const reqFee = await instance.getFee();
      // console.log(reqFee)
    })

    console.log('end');
    
    
    // massTransferer.sendMain(token.address, [rec1, rec2], [5000, 5000], {from: user, callValue: 6000000000})
    // .then(res=>{
    //   tronWrap.trx.getTransaction(res).then(console.log)
    // }).catch(err=>{
    //   console.log({err});
    // })
  // MassTransferer.deployed()
  //     .then(instance => instance.paused())
  //     .then(paused => {
  //       assert.equal(paused, false, "contract isn't deployes as unpaused");
  //     }
  // )
});

  
  // it('should deploy as unpaused', () =>{}
  // MassTransferer.deployed()
  //     .then(async ( instance) => {
  //       const get1 = await instance.get1();
  //       console.log({get1, get1FromHex: tronWrap.address.fromHex(get1)} );
  //       console.log(await instance.get2());
  //     }
  //       )
  // );


 
//   it('should call a function that depends on a linked library', () => {
//     let meta;
//     let metaCoinBalance;
//     let metaCoinEthBalance;
 
//     return MetaCoin.deployed()
//       .then(instance => {
//         meta = instance;
//         return meta.getBalance.call(accounts[0]);
//       })
//       .then(outCoinBalance => {
//         metaCoinBalance = outCoinBalance.toNumber();
//         return meta.getBalanceInEth.call(accounts[0]);
//       })
//       .then(outCoinBalanceEth => {
//         metaCoinEthBalance = outCoinBalanceEth.toNumber();
//       })
//       .then(() => {
//         assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, 'Library function returned unexpected function, linkage may be broken');
//       });
//   });
 
//   it('should send coin correctly', () => {
//     let meta;
 
//     // Get initial balances of first and second account.
//     const account_one = accounts[0];
//     const account_two = accounts[1];
 
//     let account_one_starting_balance;
//     let account_two_starting_balance;
//     let account_one_ending_balance;
//     let account_two_ending_balance;
 
//     const amount = 10;
 
//     return MetaCoin.deployed()
//       .then(instance => {
//         meta = instance;
//         return meta.getBalance.call(account_one);
//       })
//       .then(balance => {
//         account_one_starting_balance = balance.toNumber();
//         return meta.getBalance.call(account_two);
//       })
//       .then(balance => {
//         account_two_starting_balance = balance.toNumber();
//         return meta.sendCoin(account_two, amount, { from: account_one });
//       })
//       .then(() => meta.getBalance.call(account_one))
//       .then(balance => {
//         account_one_ending_balance = balance.toNumber();
//         return meta.getBalance.call(account_two);
//       })
//       .then(balance => {
//         account_two_ending_balance = balance.toNumber();
 
//         assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
//         assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
//       });
//   });
});