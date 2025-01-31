import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure users can create tasks",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "taskloom",
        "create-task",
        [
          types.ascii("Test Task"),
          types.ascii("Test Description")
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    const receipt = block.receipts[0];
    receipt.result.expectOk().expectUint(0);
  }
});

Clarinet.test({
  name: "Ensure only task creator can update task",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "taskloom",
        "create-task",
        [
          types.ascii("Test Task"),
          types.ascii("Test Description")
        ],
        deployer.address
      ),
      Tx.contractCall(
        "taskloom", 
        "update-task",
        [
          types.uint(0),
          types.ascii("Updated Title"),
          types.ascii("Updated Description")
        ],
        wallet1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectErr().expectUint(401);
  }
});
