var assert = require('assert');
var helper = require('ethereum-sandbox-helper');
var Workbench = require('ethereum-sandbox-workbench');

var workbench = new Workbench({
  contractsDirectory: 'contracts',
  solcVersion: '0.3.6',
  defaults: {
    from: '0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826'
  }
});

var providerAddress1, providerAddress2;

workbench.startTesting('provider', function(contracts) {
  it('Creates providers', function() {
    return contracts.Provider.new()
      .then(function(result) {
        if (result.address) {
          providerAddress1 = result.address;
        }
        else throw new Error('Provider contract is not deployed');
        return true;
      })
      .then(() => contracts.Provider.new())
      .then(function(result) {
        if (result.address) {
          providerAddress2 = result.address;
        }
        else throw new Error('Provider contract is not deployed');
        return true;
      });
  });
});

workbench.startTesting('pairs', function(contracts) {
  var pairsContract;

  it('Creates a pairs contract', function() {
    return contracts.Pairs.new()
      .then(function(result) {
        if (result.address) {
          pairsContract = result;
        }
        else throw new Error('Provider contract is not deployed');
        return true;
      });
  });
  
  it('Adds new pairs', function() {
    return pairsContract.submitPair('ISRC12345', 'ISWC54321', 'Hotel California', providerAddress1)
      .then(txHash => {
        return workbench.waitForReceipt(txHash);
      })
      .then(receipt => {
        const parsed = helper.hexToString(receipt.logs[0].data);
        assert.equal(parsed, 'new');
      });
  });
  
  it('Updates existing pairs', function() {
    return pairsContract.submitPair('ISRC12345', 'ISWC54321', 'Hotel California', providerAddress2)
      .then(txHash => {
        return workbench.waitForReceipt(txHash);
      })
      .then(receipt => {
        const parsed = helper.hexToString(receipt.logs[0].data);
        assert.equal(parsed, 'merged');
      });
  });
  
  it('Detects duplicate pairs', function() {
    return pairsContract.submitPair('ISRC12345', 'ISWC54321', 'Hotel California', providerAddress2)
      .then(txHash => {
        return workbench.waitForReceipt(txHash);
      })
      .then(receipt => {
        const parsed = helper.hexToString(receipt.logs[0].data);
        assert.equal(parsed, 'duplicate');
      });
  });
  
  // it('Fetches a pair', function() {
  //   return pairsContract.getPair('ISRC12345')
  //     .then(txHash => {
  //       return workbench.waitForReceipt(txHash);
  //     })
  //     .then(receipt => {
  //       const parsed = helper.hexToString(receipt.logs[0].data);
  //       assert.equal(parsed, 42);
  //     })
  // })
});
