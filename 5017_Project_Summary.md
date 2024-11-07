# Project Summary

**Project Title: Blockchain-based supply chain platform**



Project Member: 

21091193, Haibo ZHAO

21114610, Haowei TONG

## 1 Background

With the rapid development of globalization and e-commerce, the complexity of supply chains for goods continues to increase, and consumers are placing higher demands on the quality, safety, and transparency of product origins. Traditional supply chain management methods have numerous issues, such as information asymmetry, data tampering, and counterfeit goods, which not only harm consumer rights but also affect corporate reputation and market competitiveness. Therefore, we aim to establish a transparent and open platform for item information through blockchain technology to address the aforementioned problems.

## 2 Function

We plan to set two characters, commodity and user, and a user can be both Seller and Consumer.

1. Login
   1. Both roles have separate blockchain addresses for login.
2. Commodity
   1. A commodity can be bound by providing the user's address key.
   2. Commodities can upload certificates recognized by suppliers.
3. User
   1. Consumers can view and verify the certificates of commodities.
   2. A supplier can certify whether an commodity is produced by them.
   3. The user page can display which commodities the user has produced as a supplier.

## 3 Data Storage

1. Commodity
   1. Commodity information.
   2. Commodity's supplier information.
   3. Commodity's certificates.
2. User
   1. User information.
   2. User's commodities list.

## 4 Building Plan

We plan to use the React framework to build the front end, implementing the interface display of the aforementioned functionalities. In terms of integrating with the blockchain, we intend to introduce the Truffle framework to assist in storing data on the blockchain.