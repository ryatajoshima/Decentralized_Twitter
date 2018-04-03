pragma solidity ^0.4.16;

import 'zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';

contract CryptoArticleToken is ERC721Token {

  /* DATA TYPE */
  struct CryptoArticle {
    string title;
    string content;
    bool publishing;
    address mintedBy;
    uint64 mintedAt;
  }

  /* STORAGE */
  CryptoArticle[] cryptoArticles;

  mapping (uint256 => address) private tokenIndexToOwner;
  mapping (address => uint256) private ownershipTokenCount;
  mapping (address => uint256[]) private ownedTokens;
  mapping (uint256 => address) private tokenIndexToApproved;

  event Mint(address owner, uint256 tokenId);

  /* CONSTRUCTOR */
  function CryptoArticleToken(string _name, string _symbol) public ERC721Token(_name, _symbol) {}

  /* INTERNAL FUNCTIONS */
  function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return tokenIndexToOwner[_tokenId] == _claimant;
  }
  
  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownershipTokenCount[_to]++;
    tokenIndexToOwner[_tokenId] = _to;

    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      delete tokenIndexToApproved[_tokenId];
    }
    Transfer(_from, _to, _tokenId);
  }

  function _mint(string _title, string _content, bool _publishing, address _owner) internal returns (uint tokenId) {
    CryptoArticle memory cryptoArticle = CryptoArticle({
        title: _title,
        content: _content,
        publishing: _publishing,
        mintedBy: _owner,
        mintedAt: uint64(now)
      });

      tokenId = cryptoArticles.push(cryptoArticle) - 1;
      ownedTokens[_owner].push(tokenId);
      _transfer(0, _owner, tokenId);

      Mint(_owner, tokenId);
  }

  /* ERC721 IMPLEMENTATION */
  function totalSupply() public view returns (uint256) {
    return cryptoArticles.length;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return ownershipTokenCount[_owner];
  }

  function mint(string _title, string _content, bool _publishing) external returns (uint256) {
    return _mint(_title, _content, _publishing, msg.sender);
  }

  function transfer(address _to, uint256 _tokenId) external {
    require(_to != address(0));
    require(_to != address(this));
    require(_owns(msg.sender, _tokenId));

    _transfer(msg.sender, _to, _tokenId);
  }

  function getArticle(uint256 _tokenId) external view returns (string title, string content, address mintedBy, uint64 mintedAt) {
    CryptoArticle memory cryptoArticle = cryptoArticles[_tokenId];

    title = cryptoArticle.title;
    content = cryptoArticle.content;
    mintedBy = cryptoArticle.mintedBy;
    mintedAt = cryptoArticle.mintedAt;
  }

  function getAllArticlesOfOwner(address _owner) external view returns (uint256[]) {
    return ownedTokens[_owner];
  }
}