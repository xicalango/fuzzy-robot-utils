import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class CardDeck {

	// List<URL_Freq> urlList;
	private List<UrlInfo> unusedCards;
	private List<UrlInfo> usedCards;

	public CardDeck(WorkloadMix wlm) {
		this.unusedCards = new ArrayList<UrlInfo>();
		this.usedCards = new ArrayList<UrlInfo>();

		// check, if we can downscale the number of cards
		boolean downscale = true;
		for (URL_Freq f : wlm.getUrlList()) {
			if (f.getFreq() % 10 != 0) {
				downscale = false;
				break;
			}
		}

		// Scale down the number of cards, if possible
		if (downscale) {
			for (URL_Freq f : wlm.getUrlList()) {
				f.setFreq(f.getFreq() / 10);
			}
		}

		// Now set the cards by adding freq cards to the unusedCards deck
		for (URL_Freq f : wlm.getUrlList()) {
			for (int i = 0; i < f.getFreq(); i++) {
				this.unusedCards.add(f.getUrl());
			}
		}

	}

	public UrlInfo getNextCard() {

		if (this.unusedCards.size() > 0) {
			int max = this.unusedCards.size() - 1;
			Random rand = new Random();
			return this.unusedCards.get((int) (rand.nextDouble() * (max + 1)));
		} else {
			for (UrlInfo i : this.usedCards) {
				this.unusedCards.add(i);
			}
			this.usedCards.clear();
			Output.stream().println("TTT");
			return this.getNextCard();
		}
	}

	public void printUnusedCards() {
		for (UrlInfo c : this.unusedCards) {
			Output.stream().println(c);
		}
	}

}