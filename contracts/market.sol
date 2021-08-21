// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface marketPlace {
    event OrderCreated(uint256 orderType, uint256 order, address Ocontract, uint256 Oid, uint256 SOprice);
    event OrderCancelled(uint256 orderType, uint256 order);
    event OrderFulfilled(uint256 orderType, uint256 order, address Ocontract, uint256 Oid, uint256 SOprice);

    function buyOrderStats(uint256 order)
        external
        view
        returns (
            address buyer,
            address BOcontract,
            uint256 BOid,
            uint256 BOprice,
            bool BOprogress
        );

    function sellOrderStats(uint256 order)
        external
        view
        returns (
            address seller,
            address SOcontract,
            uint256 SOid,
            uint256 SOprice,
            bool SOprogress
        );

    function buy(uint256 sellOrder) external;

    function sell(uint256 buyOrder) external;

    function createBuyOrder(
        address BOcontract,
        uint256 BOid,
        uint256 BOprice
    ) external;

    function createSellOrder(
        address SOcontract,
        uint256 SOid,
        uint256 SOprice
    ) external;

    function fillBuyOrder(uint256 order) external;

    function fillSellOrder(uint256 order) external;

    function cancelBuyOrder(uint256 order) external;

    function cancelSellOrder(uint256 order) external;

    function rentOfferStats(uint256 offer)
        external
        view
        returns (
            address lord,
            address ROcontract,
            uint256 ROid,
            uint256 ROprice,
            uint256 ROperiod,
            address ROtaker,
            uint256 ROblock,
            bool ROprogress
        );

    function createRentOffer(
        address ROcontract,
        uint256 ROid,
        uint256 ROprice,
        uint256 ROperiod
    ) external;

    function takeRentOffer(uint256 offer) external;

    function cancelRentOffer(uint256 offer) external;

    function getBackNFT(uint256 offer) external;

    function loanRequestStats(uint256 offer)
        external
        view
        returns (
            address borrower,
            address LOcontract,
            uint256 LOid,
            uint256 LOamount,
            uint256 LOprepayment,
            uint256 LOperiod,
            address LOinvestor,
            uint256 LOblock,
            bool LOprogress,
            bool LOrepayed
        );

    function askForLoan(
        address LOcontract,
        uint256 LOid,
        uint256 LOamount,
        uint256 LOprepayment,
        uint256 LOperiod
    ) external;

    function giveLoan(uint256 offer) external;

    function repayLoan(uint256 offer) external;

    function claimLoanNFT(uint256 offer) external;

    function cancelLoan(uint256 offer) external;
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract NFTmarketplace is marketPlace {
    uint256 _sellOrders;
    mapping(uint256 => address) private _seller;
    mapping(uint256 => address) private _SOcontract;
    mapping(uint256 => uint256) private _SOid;
    mapping(uint256 => uint256) private _SOprice;
    mapping(uint256 => bool) private _SOprogress;

    uint256 _buyOrders;
    mapping(uint256 => address) private _buyer;
    mapping(uint256 => address) private _BOcontract;
    mapping(uint256 => uint256) private _BOid;
    mapping(uint256 => uint256) private _BOprice;
    mapping(uint256 => bool) private _BOprogress;

    uint256 _rentOffers;
    mapping(uint256 => address) private _lord;
    mapping(uint256 => address) private _ROcontract;
    mapping(uint256 => uint256) private _ROid;
    mapping(uint256 => uint256) private _ROprice;
    mapping(uint256 => uint256) private _ROperiod;
    mapping(uint256 => address) private _ROtaker;
    mapping(uint256 => uint256) private _ROblock; //block user rented it on
    mapping(uint256 => bool) private _ROprogress;

    uint256 _loanOffers;
    mapping(uint256 => address) private _borrower;
    mapping(uint256 => address) private _LOcontract;
    mapping(uint256 => uint256) private _LOid;
    mapping(uint256 => uint256) private _LOamount;
    mapping(uint256 => uint256) private _LOprepayment;
    mapping(uint256 => uint256) private _LOperiod;
    mapping(uint256 => address) private _LOinvestor;
    mapping(uint256 => uint256) private _LOblock; //block user borrowed it on
    mapping(uint256 => bool) private _LOprogress;
    mapping(uint256 => bool) private _LOrepayed;

    IERC20 NGL;

    constructor(address NGLcontract) {
        NGL = IERC20(NGLcontract);
    }

    //==============================================================================================================================================================================================================
    function buyOrderStats(uint256 order)
        external
        view
        override
        returns (
            address buyer,
            address BOcontract,
            uint256 BOid,
            uint256 BOprice,
            bool BOprogress
        )
    {
        buyer = _buyer[order];
        BOcontract = _BOcontract[order];
        BOid = _BOid[order];
        BOprice = _BOprice[order];
        BOprogress = _BOprogress[order];
    }

    function sellOrderStats(uint256 order)
        external
        view
        override
        returns (
            address seller,
            address SOcontract,
            uint256 SOid,
            uint256 SOprice,
            bool SOprogress
        )
    {
        seller = _seller[order];
        SOcontract = _SOcontract[order];
        SOid = _SOid[order];
        SOprice = _SOprice[order];
        SOprogress = _SOprogress[order];
    }

    function buy(uint256 sellOrder) external override {
        require(!_SOprogress[sellOrder]);
        NGL.transferFrom(msg.sender, _seller[sellOrder], _SOprice[sellOrder]);

        IERC721 NFT = IERC721(_SOcontract[sellOrder]);
        NFT.safeTransferFrom(address(this), msg.sender, _SOid[sellOrder]);

        _SOprogress[sellOrder] = true;
    }

    function sell(uint256 buyOrder) external override {
        require(!_BOprogress[buyOrder]);

        IERC721 NFT = IERC721(_BOcontract[buyOrder]);
        NFT.safeTransferFrom(msg.sender, _buyer[buyOrder], _BOid[buyOrder]);

        NGL.transfer(msg.sender, _BOprice[buyOrder]);

        _BOprogress[buyOrder] = true;
    }

    function createBuyOrder(
        address BOcontract,
        uint256 BOid,
        uint256 BOprice
    ) external override {
        NGL.transferFrom(msg.sender, address(this), BOprice);
        uint256 buyOrders = _buyOrders;
        _buyer[buyOrders] = msg.sender;
        _BOcontract[buyOrders] = BOcontract;
        _BOid[buyOrders] = BOid;
        _BOprice[buyOrders] = BOprice;
        ++_buyOrders;
    }

    function createSellOrder(
        address SOcontract,
        uint256 SOid,
        uint256 SOprice
    ) external override {
        IERC721 NFT = IERC721(SOcontract);
        NFT.safeTransferFrom(msg.sender, address(this), SOid);
        uint256 sellOrders = _sellOrders;
        _seller[sellOrders] = msg.sender;
        _SOcontract[sellOrders] = SOcontract;
        _SOid[sellOrders] = SOid;
        _SOprice[sellOrders] = SOprice;
        ++_sellOrders;
    }

    function fillBuyOrder(uint256 order) external override {
        require(!_BOprogress[order]);
        IERC721 NFT = IERC721(_BOcontract[order]);
        NFT.safeTransferFrom(msg.sender, _buyer[order], _BOid[order]);
        NGL.transfer(msg.sender, _BOprice[order]);
        _BOprogress[order] = true;
    }

    function fillSellOrder(uint256 order) external override {
        require(!_SOprogress[order]);
        NGL.transferFrom(msg.sender, _seller[order], _SOprice[order]);
        IERC721 NFT = IERC721(_SOcontract[order]);
        NFT.safeTransferFrom(address(this), msg.sender, _SOid[order]);
        _SOprogress[order] = true;
    }

    function cancelBuyOrder(uint256 order) external override {
        require(!_BOprogress[order] && msg.sender == _buyer[order]);
        NGL.transferFrom(address(this), msg.sender, _BOprice[order]);
        _BOprogress[order] = true;
    }

    function cancelSellOrder(uint256 order) external override {
        require(!_SOprogress[order] && msg.sender == _seller[order]);
        IERC721 NFT = IERC721(_SOcontract[order]);
        NFT.safeTransferFrom(address(this), msg.sender, _SOid[order]);
        _SOprogress[order] = true;
    }

    //==============================================================================================================================================================================================================
    function rentOfferStats(uint256 offer)
        external
        view
        override
        returns (
            address lord,
            address ROcontract,
            uint256 ROid,
            uint256 ROprice,
            uint256 ROperiod,
            address ROtaker,
            uint256 ROblock,
            bool ROprogress
        )
    {
        lord = _lord[offer];
        ROcontract = _ROcontract[offer];
        ROid = _ROid[offer];
        ROprice = _ROprice[offer];
        ROperiod = _ROperiod[offer];
        ROtaker = _ROtaker[offer];
        ROblock = _ROblock[offer];
        ROprogress = _ROprogress[offer];
    }

    function createRentOffer(
        address ROcontract,
        uint256 ROid,
        uint256 ROprice,
        uint256 ROperiod
    ) external override {
        IERC721 NFT = IERC721(ROcontract);
        NFT.safeTransferFrom(msg.sender, address(this), ROid);
        uint256 offers = _rentOffers;
        _lord[offers] = msg.sender;
        _ROcontract[offers] = ROcontract;
        _ROid[offers] = ROid;
        _ROprice[offers] = ROprice;
        _ROperiod[offers] = ROperiod;
        ++_rentOffers;
    }

    function takeRentOffer(uint256 offer) external override {
        require(!_ROprogress[offer]);
        NGL.transferFrom(msg.sender, _lord[offer], _ROprice[offer]);

        _ROtaker[offer] = msg.sender;
        _ROblock[offer] = block.number;
        _ROprogress[offer] = true;
    }

    function cancelRentOffer(uint256 offer) external override {
        require(!_ROprogress[offer] && msg.sender == _lord[offer]);
        IERC721 NFT = IERC721(_ROcontract[offer]);
        NFT.safeTransferFrom(address(this), msg.sender, _ROid[offer]);
        _ROprogress[offer] = true;
    }

    function getBackNFT(uint256 offer) external override {
        require(_ROprogress[offer] && block.number - _ROblock[offer] > _ROperiod[offer]);
        IERC721 NFT = IERC721(_ROcontract[offer]);
        NFT.safeTransferFrom(address(this), _lord[offer], _ROid[offer]);
    }

    //==============================================================================================================================================================================================================

    function loanRequestStats(uint256 offer)
        external
        view
        override
        returns (
            address borrower,
            address LOcontract,
            uint256 LOid,
            uint256 LOamount,
            uint256 LOprepayment,
            uint256 LOperiod,
            address LOinvestor,
            uint256 LOblock,
            bool LOprogress,
            bool LOrepayed
        )
    {
        borrower = _borrower[offer];
        LOcontract = _LOcontract[offer];
        LOid = _LOid[offer];
        LOamount = _LOamount[offer];
        LOprepayment = _LOprepayment[offer];
        LOperiod = _LOperiod[offer];
        LOinvestor = _LOinvestor[offer];
        LOblock = _LOblock[offer];
        LOprogress = _LOprogress[offer];
        LOrepayed = _LOrepayed[offer];
    }

    function askForLoan(
        address LOcontract,
        uint256 LOid,
        uint256 LOamount,
        uint256 LOprepayment,
        uint256 LOperiod
    ) external override {
        IERC721 NFT = IERC721(LOcontract);
        NFT.safeTransferFrom(msg.sender, address(this), LOid);
        NGL.transferFrom(msg.sender, address(this), LOprepayment);
        uint256 offers = _loanOffers;
        _borrower[offers] = msg.sender;
        _LOcontract[offers] = LOcontract;
        _LOid[offers] = LOid;
        _LOamount[offers] = LOamount;
        _LOprepayment[offers] = LOprepayment;
        _LOperiod[offers] = LOperiod;
        ++_loanOffers;
    }

    function giveLoan(uint256 offer) external override {
        require(!_LOprogress[offer]);
        NGL.transferFrom(msg.sender, _borrower[offer], _LOamount[offer]);
        NGL.transfer(msg.sender, _LOprepayment[offer]);
        _LOinvestor[offer] = msg.sender;
        _LOblock[offer] = block.number;
        _LOprogress[offer] = true;
    }

    function repayLoan(uint256 offer) external override {
        require(block.number - _LOblock[offer] <= _LOperiod[offer]);
        require(msg.sender == _borrower[offer]);
        NGL.transferFrom(msg.sender, _LOinvestor[offer], _LOamount[offer]);
        IERC721 NFT = IERC721(_LOcontract[offer]);
        NFT.safeTransferFrom(address(this), msg.sender, _LOid[offer]);
        _LOrepayed[offer] = true;
    }

    function claimLoanNFT(uint256 offer) external override {
        require(block.number - _LOblock[offer] > _LOperiod[offer]);
        require(msg.sender == _LOinvestor[offer]);
        IERC721 NFT = IERC721(_LOcontract[offer]);
        NFT.safeTransferFrom(address(this), msg.sender, _LOid[offer]);
    }

    function cancelLoan(uint256 offer) external override {
        require(!_LOprogress[offer]);
        require(msg.sender == _borrower[offer]);
        IERC721 NFT = IERC721(_LOcontract[offer]);
        NFT.safeTransferFrom(address(this), msg.sender, _LOid[offer]);
        _LOprogress[offer] = true;
    }
}
