// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

// 看涨期权金库
// 看涨期权锁定的是标的资产，如WETH
interface ICallOptionVault {
    // 卖出看涨期权，要从金库中锁定指定数量的资产，避免卖家在期权到期日前提前取出资产
    // 确保买家行权时能够正常交割
    function lock(address sender, uint256 amount, uint256 tokenId) external;

    // 看涨期权到期日后，买家未行权，卖家可主动解锁冻结的资产，欧式期权行权日只有一天
    function unlock(address sender, uint256 amount, uint256 tokenId) external;

    // 看涨期权到期日，买家行权，将卖家冻结的资产转移到买家账户
    function exercise(address sender, uint256 tokenId) external;

    // 看涨期权，已行权，可选择燃烧掉票据，避免保存无意义的期权数据
    function burn(address sender, uint256 tokenId) external;
}


// 看跌期权金库
// 看跌期权锁定的是行权资产，如USDT
interface IPutOptionVault {
    function lock(address sender, uint256 amount, uint256 tokenId) external;

    function unlock(address sender, uint256 amount, uint256 tokenId) external;

    function exercise(address sender, uint256 tokenId) external;

    function burn(address sender, uint256 tokenId) external;
}
