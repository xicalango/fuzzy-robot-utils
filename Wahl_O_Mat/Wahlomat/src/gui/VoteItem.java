package gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.border.BevelBorder;

public class VoteItem <T> extends JPanel implements MouseListener{

	private T voteEntity;
	JLabel leftLabel;
	JLabel middleLabel;
	private JPanel rightPanel;
	private JRadioButton button;
	
	public VoteItem(JLabel left, JLabel middle, JRadioButton button, T voteEntity){
		super();

		this.leftLabel = left;
		this.middleLabel = middle;
		rightPanel = new JPanel();
		
		this.voteEntity = voteEntity;
		
		this.button = button;		
		this.rightPanel.add(button);
		
		this.addMouseListener(this);		
		
		this.setLayout(new FlowLayout());				
		
		this.add(leftLabel);
		this.add(middleLabel);
		this.add(rightPanel);	
		
		this.setBorder(BorderFactory.createLineBorder(Color.gray, 1));
	}
	
	
	public T getVoteEntity(){
		return this.voteEntity;
	}
	
	public boolean isSelected(){
		return this.button.isSelected();
	}	
	
	public void setSize(Dimension left, Dimension middle, Dimension right){
		this.leftLabel.setPreferredSize(left);
		this.middleLabel.setPreferredSize(middle);
		this.rightPanel.setPreferredSize(right);
	}
	
	public Dimension getLeftDimension(){
		return this.leftLabel.getPreferredSize();
	}
	
	public Dimension getMiddleDimension(){
		return this.middleLabel.getPreferredSize();
	}
	
	public Dimension getRightDimension(){
		return this.rightPanel.getPreferredSize();
	}

	@Override
	public void mouseClicked(MouseEvent arg0) {
		this.button.doClick();
	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mousePressed(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseReleased(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}
	

	
	
}
