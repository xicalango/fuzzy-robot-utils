package gui;

import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.ComponentOrientation;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextField;

import org.postgresql.util.PSQLException;

import domain.District;
import domain.FederalState;

import persistence.DataHandler;
import persistence.IDataHandler;

public class LoginWindow extends JFrame implements ActionListener{

	private JPasswordField admin_passwdTextField;
	private JTextField urlTextField;
	private JTextField usernameTextField;
	private JPasswordField dbPasswdTextField;
	private IDataHandler dh;
	private String presetDBUrl = "jdbc:postgresql://minitux.dyndns.org:5432/btw2009";
	private String presetDBUserName = "btw2009";
	private String presetDBPassword = "btw2009";
	private char[] login;
	
	public LoginWindow(IDataHandler dh, char[] login){
		super();
		
		this.dh = dh;
		this.login = login;
		
		JPanel adminPasswdPanel = new JPanel();		
		JLabel adminPasswdlabel = new JLabel("Administrator-Passwort:");
		admin_passwdTextField = new JPasswordField();
		admin_passwdTextField.setColumns(20);
		adminPasswdPanel.add(adminPasswdlabel);
		adminPasswdPanel.add(admin_passwdTextField);
		
		JPanel urlPanel = new JPanel();
		JLabel urlLabel = new JLabel("Bitte URL zur Datenbank eintragen");
		urlTextField = new JTextField(this.presetDBUrl);
		urlTextField.setColumns(20);
		urlPanel.add(urlLabel);
		urlPanel.add(urlTextField);
		
		JPanel usernamePanel = new JPanel();
		JLabel usernameLabel = new JLabel("Bitte Benutzername der Datenbank eintragen");
		usernameTextField = new JTextField(this.presetDBUserName);
		usernameTextField.setColumns(20);
		usernamePanel.add(usernameLabel);
		usernamePanel.add(usernameTextField);
		
		JPanel dbPasswdPanel = new JPanel();
		JLabel dbPasswdLabel = new JLabel("Bitte Passwort der Datenbank eintragen");
		
		dbPasswdTextField = new JPasswordField(this.presetDBPassword);
		dbPasswdTextField.setColumns(20);
		dbPasswdPanel.add(dbPasswdLabel);
		dbPasswdPanel.add(dbPasswdTextField);
		
		
		JPanel buttonPanel = new JPanel();
		JButton b = new JButton("Anmelden");
		buttonPanel.add(b);	
		b.addActionListener(this);
			
		this.setLayout(new GridLayout(5,1));	
		
		this.add(urlPanel);
		this.add(usernamePanel);
		this.add(dbPasswdPanel);
		this.add(adminPasswdPanel);
		this.add(buttonPanel);
		
			
		this.pack();
		this.setVisible(true);
		
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		if(this.validateLogin()){
			try {
				
				this.dh.setDBUrl(this.urlTextField.getText());
				
				this.dh.setDBUserName(this.usernameTextField.getText());
				
				this.dh.setDBPasswd(new String(this.dbPasswdTextField.getPassword()));
								
				this.dh.establishConnection();
				
				List<District> districts = this.dh.getDistricts();
				List<FederalState> states = this.dh.getFederalStates();
				
				this.dh.closeConnection();
				
				new AdminWindow(districts, states, this.dh);
				
				this.dispose();
			}
			catch (PSQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			
		}
	}
	
	private boolean validateLogin(){
		if(Arrays.equals(admin_passwdTextField.getPassword(),this.login)) return true;
		return false;
	}
	
	
	
	
}
