package jp.co.dcs21.migration.utils;

import java.util.ArrayList;
import java.util.List;

public class Configs {

	private List<Config> configs = new ArrayList<Config>();
	
	public void addConfig(Config conf) {
		configs.add(conf);
	}

	/**
	 * @return the configs
	 */
	public List<Config> getConfigs() {
		return configs;
	}

	/**
	 * @param configs the configs to set
	 */
	public void setConfigs(List<Config> configs) {
		this.configs = configs;
	}
	
	
	
}
