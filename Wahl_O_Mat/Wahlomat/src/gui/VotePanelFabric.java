package gui;

import java.awt.Dimension;
import java.awt.Font;
import java.util.ArrayList;
import java.util.List;

import javax.swing.ButtonGroup;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;

import domain.BallotCard;
import domain.DCandidate;
import domain.LCandidate;
import domain.Party;
import domain.PartyList;

public class VotePanelFabric {

	
	public static VotePanel<DCandidate> getFirstVotePanel(BallotCard bCard){

		List<VoteItem<DCandidate>> voteItems = new ArrayList<VoteItem<DCandidate>>();
		
		ButtonGroup bg = new ButtonGroup();
		
		for(DCandidate d : bCard.getdCandidateList()){
			
			JLabel candLabel = new JLabel("<html>" + d.getFirstName() + "<p/>" + d.getLastName() + "</html>");	
			candLabel.setFont(new Font("Arial", Font.BOLD, 25));
			JLabel partyLabel = new JLabel("<html>" + " Parteilos " + "</html>");
			if(d.getParty()!=null){
			partyLabel = new JLabel("<html>" + d.getParty().toString() + "</html>");		
			}
			partyLabel.setFont(new Font("Arial", Font.ITALIC, 18));
			JRadioButton button = new JRadioButton();
			bg.add(button);
			
			voteItems.add(new VoteItem<DCandidate>(candLabel, partyLabel, button, d));
		}
		
		 return new VotePanel<DCandidate>("Erststimme", voteItems);		
	}
	
	public static VotePanel<PartyList> getSecondVotePanel(BallotCard bCard){

		List<VoteItem<PartyList>> voteItems = new ArrayList<VoteItem<PartyList>>();
		
		ButtonGroup bg = new ButtonGroup();
		
		for(PartyList pl : bCard.getPartyList()){
			
			JLabel partyNameLabel = new JLabel("<html>" + pl.getParty().toString() + "</html>");	
			partyNameLabel.setFont(new Font("Arial", Font.BOLD, 25));
			
			String candidateLabelString = "<html>";
			
			for(LCandidate d : pl.getCandidates()){
				candidateLabelString = candidateLabelString + d.getFirstName() + " " + d.getLastName()+"<p/>";
			}
			
			candidateLabelString = candidateLabelString + "<html>";
			
			JLabel candListLabel = new JLabel(candidateLabelString);		
			
			//candListLabel.setPreferredSize(new Dimension(1000,200));
			
			JRadioButton button = new JRadioButton();
			bg.add(button);
			
			voteItems.add(new VoteItem<PartyList>(partyNameLabel, candListLabel, button, pl));
		}
		
		 return new VotePanel<PartyList>("Zweitstimme", voteItems);		
	}
	
	
}
