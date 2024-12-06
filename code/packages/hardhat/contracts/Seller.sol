// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoyaltyPoints is ERC20, Ownable {
    // attribute
    string private tokenName;  // Token Name
    uint256 private reserveAmount;  //  Seller's total reserve amount in USDT
    uint256 private tokenValueInUSDT;  // issued token value in USDT
    uint256 private monthlyAverageProfit; // monthly average profit
    uint256 private expirationTime;  // withdraw token's expiration time

    address private tempAddress;
    // constant
    uint256 constant DECIMALS = 18;
    uint256 constant MULTIPLIER = 10 ** DECIMALS;
    
    // Rate div 10**DECIMALS
    uint256 private reserveRate = 8 * 10 **(DECIMALS-2);
    uint256 private tokenValueRate = 1 * 10 ** (DECIMALS-5);
    uint256 private rewardRate = 1 * 10 ** (DECIMALS-2);
    uint256 private referrerRate = 1 * 10 ** (DECIMALS-3);
    // 净利润 = 消费额 * 15%

    // 分发的token = [消费额 * 1%, 消费额 * 1.2%] = [, 净利润 * 8%]
    // 储备池 = 净利润 * 8%
    // token价格 = 净利润 * 0.00001 = 储备池 * 1/8000

    // (当前月的储备池 + (之前的储备池-totalSuppply) * tokenValueInUSDT) * tokenValueRate
    // 80%

    struct withdrawInfo{
        uint256 amount;
        uint256 timeStamp;
    }
    mapping(address => withdrawInfo) public withdrawableAmounts;

    constructor(
        string memory _tokenName,
        uint256 _monthlyAverageProfit,
        address initialOwner
    ) ERC20(_tokenName, "LP") Ownable(initialOwner) {
        tokenName = _tokenName;
//        reserveAmount = _reserveAmount * MULTIPLIER; // 使用 MULTIPLIER 处理小数位数
//        tokenValueInUSDT = _tokenValueInUSDT * MULTIPLIER; // 使用 MULTIPLIER 处理小数位数
        monthlyAverageProfit = _monthlyAverageProfit * MULTIPLIER; // 使用 MULTIPLIER 处理小数位数
        reserveAmount = monthlyAverageProfit * reserveRate / MULTIPLIER;
        tokenValueInUSDT = monthlyAverageProfit * tokenValueRate / MULTIPLIER;
        expirationTime = block.timestamp;
    }

//    function Token_Name() public view returns (string memory) {
//        return tokenName;
//    }

    function Temp_Address() public view returns (address) {
        return tempAddress; // 返回实际值
    }

    function Token_Value_in_USDT() public view returns (uint256) {
        return tokenValueInUSDT; // 返回实际值
    }

    function Reserve_Amount() public view returns (uint256) {
        return reserveAmount; // 返回实际值
    }

//    function Set_Token_Name(string memory _newTokenName) public onlyOwner returns(bool) {
//        tokenName = _newTokenName;
//        return true;
//    }

    // 每个月底商家上传利润，根据利润更新reserveAmount和tokenValueInUSDT
    function Issue_Profit(uint256 _monthlyAverageProfit) public onlyOwner returns (uint256) {
        uint256 dividendRate;
        if (_monthlyAverageProfit <= 50000){
            dividendRate = 5 * 10 **(DECIMALS-2);
        }
        else if(_monthlyAverageProfit > 50000 && _monthlyAverageProfit <= 100000){
            dividendRate = 10 * 10 **(DECIMALS-2);
        }
        else if(_monthlyAverageProfit > 100000){
            dividendRate = 20 * 10 **(DECIMALS-2);
        }

        monthlyAverageProfit = _monthlyAverageProfit * MULTIPLIER;
        uint256 leftReserveAmount = reserveAmount * MULTIPLIER - totalSupply() * tokenValueInUSDT;
        // 新的tokenValueInUSDT = 当前月利润 * tokenValueRate + 储备池剩余 * tokenValueInUSDT * DividendRate / totalSupply()
        uint256 dividendPerToken = leftReserveAmount / totalSupply() * dividendRate / MULTIPLIER;
        if (dividendPerToken > MULTIPLIER){
            dividendPerToken = MULTIPLIER; // 限制最大分红为每个token 1USDT
        }
        //根据新的token价格更新储备池金额
        reserveAmount = totalSupply() * tokenValueInUSDT / MULTIPLIER + leftReserveAmount / MULTIPLIER * dividendRate / MULTIPLIER +  monthlyAverageProfit * reserveRate / MULTIPLIER;

        expirationTime = block.timestamp;
        return tokenValueInUSDT;
    }

    // 函数1：
    function generateMintingAddressesA(uint256 orderAmount) public returns (address) {
        address addressA = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)))));

        uint256 amountA = (orderAmount * MULTIPLIER / tokenValueInUSDT) * rewardRate; // 4.5%

//        _mint(addressA, amountA);
        withdrawableAmounts[addressA] = withdrawInfo(
            amountA,
            block.timestamp
        );

        tempAddress = addressA;

        return addressA;
    }

    function generateMintingAddressesB(uint256 orderAmount, address referrer) public returns (address) {
        address temp_address = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)))));

        uint256 amountA = (orderAmount * MULTIPLIER / tokenValueInUSDT) * (rewardRate + referrerRate); // 3.2%
        uint256 amountB = (orderAmount * MULTIPLIER / tokenValueInUSDT) * referrerRate; // 0.25%

        withdrawableAmounts[temp_address] = withdrawInfo(
            amountA,
            block.timestamp
        );

        tempAddress = temp_address;

//        _mint(temp_address, amountA);
        _mint(referrer, amountB);

        return temp_address;
    }

    // 从之前的暂存地址，转移代币到用户地址
    function withdrawTokens(address withdrawAddress) public returns (uint256) {
        require(withdrawableAmounts[withdrawAddress].amount > 0, "No tokens available for withdrawal");


        uint256 amount = withdrawableAmounts[withdrawAddress].amount;
        uint256 oldTimeStamp = withdrawableAmounts[withdrawAddress].timeStamp;
        require(expirationTime < oldTimeStamp, "Token has expired");

        withdrawableAmounts[withdrawAddress].amount = 0;

        _mint(msg.sender, amount);
//        _transfer(withdrawAddress, msg.sender, amount);

        return amount;
    }
    
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
//    function transfer(address to, uint256 amount) public override {
//        _transfer(_msgSender(), to, amount);
//        return;
//    }
}