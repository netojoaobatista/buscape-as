package com.buscape.developer.result {
	/**
	 * Country code of API call response.
	 * 
	 * @author João Batista Neto
	 */
	public final class CountryCode {
		public static const AR :CountryCode = new CountryCode( 'AR' );
		public static const BR :CountryCode = new CountryCode( 'BR' );
		public static const CL :CountryCode = new CountryCode( 'CL' );
		public static const CO :CountryCode = new CountryCode( 'CO' );
		public static const MX :CountryCode = new CountryCode( 'MX' );
		public static const PE :CountryCode = new CountryCode( 'PE' );
		public static const VE :CountryCode = new CountryCode( 'VE' );
		
		private var countryCode :String;
		
		public function CountryCode( countryCode :String ) {
			switch ( countryCode ) {
				case 'AR':
				case 'BR':
				case 'CL':
				case 'CO':
				case 'MX':
				case 'PE':
				case 'VE':
					this.countryCode = countryCode;
					break;
				default:
					throw new Error( 'Código de país inválido' );
			}
		}
		
		/**
		 * Returns the string representation of CountryCode
		 */
		public function toString() :String {
			return this.countryCode;
		}
	}
}