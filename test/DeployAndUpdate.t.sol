//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {DeployBox} from "../script/DeployBox.s.sol";


contract DeployAndUpdate is Test {

    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public OWNER = makeAddr("owner");

    address public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run();
    }

    function testUpgrades() public {
        BoxV2 box2 = new BoxV2();
        console.log(address(proxy));

        upgrader.upgradeBox(proxy, address(box2));
        console.log(address(proxy));
        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxy).version());
        BoxV2(proxy).setNumber(82);
        assertEq(82,  BoxV2(proxy).getNumber());
    }

    function testProxyStartsAsBoxV1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(82);

        BoxV2 box2 = new BoxV2();
        BoxV1 box1 = new BoxV1();
        proxy = upgrader.upgradeBox(proxy, address(box2));
        console.log(address(proxy));

        BoxV2(proxy).setNumber(82);
        assertEq(82,  BoxV2(proxy).getNumber());

        upgrader.upgradeBox(proxy, address(box1));
        console.log(address(proxy));

        vm.expectRevert();
        BoxV2(proxy).setNumber(82);
    }
}