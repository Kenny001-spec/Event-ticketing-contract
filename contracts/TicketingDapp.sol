// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IEventTicketing} from "./IEventTicketing.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TicketManager is Ownable {
    IEventTicketing public eventTicketing; 

    enum TicketStatus { Available, Purchased, Used }

    string constant URI = "https://glad-tomato-cobra.myfilebase.com/ipfs/QmQKhzfhn95gYj71MLPHHvyxfvPPY49aWz1TyeREMYyPw2";

    struct Ticket {
        uint256 id; 
        address owner; 
        TicketStatus status; 
    }

    uint256 public ticketPrice;
    bool public eventStarted = false; 
    mapping(uint256 => Ticket) public tickets; 
    uint256 private _nextTicketId; 

    event TicketMinted(uint256 indexed ticketId);
    event TicketPurchased(uint256 indexed ticketId, address indexed buyer);
    event TicketUsed(uint256 indexed ticketId);
    event EventStarted();

    constructor(IEventTicketing eventTicketingAddress, uint256 _ticketPrice) Ownable(msg.sender) {
        eventTicketing = eventTicketingAddress; 
        ticketPrice = _ticketPrice; 
    }


    


    function startEvent() public onlyOwner {
        eventStarted = true; 
        emit EventStarted(); 
    }

    function mintTicket() public onlyOwner {
        require(!eventStarted, "Event has already started, no more tickets can be minted.");

        uint256 ticketId = _nextTicketId++;
     
        eventTicketing.safeMint(msg.sender, URI); 

        tickets[ticketId] = Ticket({
            id: ticketId,
            owner: msg.sender,
            status: TicketStatus.Available
        });

        emit TicketMinted(ticketId); 
    }

    function purchaseTicket(uint256 ticketId) public payable {
        require(!eventStarted, "Event has already started, tickets can no longer be purchased.");
        require(tickets[ticketId].status == TicketStatus.Available, "Ticket not available.");
        require(msg.value >= ticketPrice, "Insufficient funds to purchase ticket.");

        eventTicketing.safeMint(msg.sender, URI); 

        tickets[ticketId].status = TicketStatus.Purchased;
        tickets[ticketId].owner = msg.sender;

        emit TicketPurchased(ticketId, msg.sender); 
    }

    function useTicket(uint256 ticketId) public {
        require(eventStarted, "Event has not started yet.");
        require(tickets[ticketId].owner == msg.sender, "Only the ticket owner can use it.");
        require(tickets[ticketId].status == TicketStatus.Purchased, "Ticket has already been used or is unavailable.");

        tickets[ticketId].status = TicketStatus.Used;

        emit TicketUsed(ticketId); 
    }

    function withdrawFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
