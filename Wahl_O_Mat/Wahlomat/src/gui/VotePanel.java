package gui;

import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.border.BevelBorder;

import domain.NoVotePerformedException;

public class VotePanel <T> extends JPanel {

	List<VoteItem<T>> voteItems;
	JLabel descriptionLabel;
	
	
	public VotePanel(String description, List<VoteItem<T>> voteItems){
		this.voteItems = voteItems;
		this.descriptionLabel = new JLabel(description);
						
		this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
		
		this.add(descriptionLabel);
		
		for(VoteItem i : this.voteItems){
			this.add(i);
		}		
		this.setSize();
		this.setBorder(BorderFactory.createBevelBorder(BevelBorder.LOWERED));
	}
	
	public T getVote() throws NoVotePerformedException{
		for(VoteItem<T> i : this.voteItems){
			if(i.isSelected()){
				return (T) i.getVoteEntity();
			}
		}
		throw new NoVotePerformedException("No vote performed...");
		}
	
	private void setSize(){
		int maxLeftWidth = 0;
		int maxMiddleWidth = 0;
		int maxRightWidth = 0;
		for(VoteItem<T> i : voteItems){
			if(maxLeftWidth < i.getLeftDimension().width){
				maxLeftWidth = i.getLeftDimension().width;
			}
			if(maxMiddleWidth < i.getMiddleDimension().width){
				maxMiddleWidth = i.getMiddleDimension().width;
			}
			if(maxRightWidth < i.getRightDimension().width){
				maxRightWidth = i.getRightDimension().width;
			}
		}
		for(VoteItem<T> i : voteItems){
			i.setSize(new Dimension(maxLeftWidth+5, i.getLeftDimension().height), new Dimension(maxMiddleWidth+5, i.getMiddleDimension().height), new Dimension(maxRightWidth, i.getRightDimension().height));
		}
	}
	
	
}
